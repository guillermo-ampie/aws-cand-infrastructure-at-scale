# TODO: Define the variable for aws_region
variable "aws_region" {
  description = "The VPC region for regional-bound resources"
  type        = string
  default     = "us-east-1" # Default region
}
