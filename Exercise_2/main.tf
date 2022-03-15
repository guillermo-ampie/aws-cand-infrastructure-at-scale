#
# Definition file for lambda function: 
# - lambda function: greet
# - runtime: python
# - source file: greet_lambda.py
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0.10"
}

provider "aws" {
  # The AWS profile used for this project
  profile = "arch"

  region = var.aws_region
}

locals {
  project = "CAND Infrastucture at Scale"
  tier    = "dev"

  lambda_source_file = "greet_lambda.py"
  artifact_pathname  = "lambda/greet_lambda.zip"
  runtime            = "python3.8"
  function_name      = "greet"
  function_handler   = "greet_lambda.lambda_handler"
  lambda_role_name   = "lambda_role"
}

#
# Create an S3 bucket
#
resource "aws_s3_bucket" "lambda_bucket" {
  bucket_prefix = "lambda-"
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" # Server-side encryption: Amazon S3 master-key (SSE-S3)
      }
    }
  }

  tags = {
    Project = local.project
    Tier    = local.tier
  }
}

# Set up "no public" access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.lambda_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Package and upload the lambda function to the S3 bucket
#
data "archive_file" "lambda_greet" {
  type = "zip"

  source_file = "./${local.lambda_source_file}"
  output_path = "./${local.artifact_pathname}"
}

resource "aws_s3_bucket_object" "lambda_greet" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = local.artifact_pathname
  source = data.archive_file.lambda_greet.output_path

  etag = filemd5(data.archive_file.lambda_greet.output_path)
}

#
# Create lambda function
#
resource "aws_lambda_function" "greet" {
  function_name = local.function_name

  # S3 bucket that stores the lambda function
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_greet.key

  runtime = local.runtime
  handler = local.function_handler

  # When the hash code changes the Lambda service knows there is a new function version
  source_code_hash = data.archive_file.lambda_greet.output_base64sha256

  # The lambda's execution role
  role = aws_iam_role.lambda_exec_role.arn

  environment {
    # greeting: environment var used in the lambda function
    variables = {
      greeting = "That's all folks"
    }
  }
}

# Lambda function's execution role
resource "aws_iam_role" "lambda_exec_role" {
  name = local.lambda_role_name

  # "Trust policy" definition, for details see:
  # https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Add permission to the role:
# AWSLambdaBasicExecutionRole – Permission to upload logs to CloudWatch, for detailss see:
# https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch log group for lambda function "greet": /aws/lambda/greet/XXXXXX
resource "aws_cloudwatch_log_group" "log_group_lambda_greet" {
  name = "/aws/lambda/${aws_lambda_function.greet.function_name}"

  retention_in_days = 14
}
