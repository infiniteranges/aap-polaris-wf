/**
 * Lambda Function Module
 * 
 * Creates an AWS Lambda function with configurable runtime, handler, and code.
 * This module uses terraform-aws-modules/terraform-aws-lambda
 */

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# Create a zip file from the source code directory or file
data "archive_file" "lambda_zip" {
  count = var.source_path != null ? 1 : 0

  type        = "zip"
  source_file = var.source_path
  output_path = "${path.module}/lambda_function.zip"
}

# Use the terraform-aws-modules Lambda module
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = var.function_name
  description   = var.description
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  # IAM role for Lambda execution
  create_role = false
  lambda_role = var.iam_role_arn

  # Source code
  create_package         = var.source_path != null
  local_existing_package = var.source_path != null ? data.archive_file.lambda_zip[0].output_path : null
  s3_existing_package = var.s3_bucket != null && var.s3_key != null ? {
    bucket = var.s3_bucket
    key    = var.s3_key
  } : null

  # Environment variables
  environment_variables = var.environment_variables

  # VPC configuration (optional)
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  attach_network_policy  = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0

  # Dead letter queue (optional)
  dead_letter_target_arn = var.dead_letter_queue_arn

  # Tags
  tags = merge(
    var.tags,
    {
      Name      = var.function_name
      Component = "lambda-function"
      ManagedBy = "polaris-stack"
    }
  )
}
