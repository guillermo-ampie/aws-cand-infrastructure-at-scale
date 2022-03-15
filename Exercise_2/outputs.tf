# TODO: Define the output variable for the lambda function.
output "aws_region" {
  description = "AWS Region selected"

  value = var.aws_region
}

output "lambda_bucket_name" {
  description = "S3 bucket used to store the lambda function code"

  value = aws_s3_bucket.lambda_bucket.id
}

output "lambda_function_name" {
  description = "Lambda function name"

  value = aws_lambda_function.greet.function_name
}

output "lambda_greet_arn" {
  description = "Lambda function arn name"

  value = aws_lambda_function.greet.arn
}

