/**
 * IAM Lambda Execution Role Module
 * 
 * Creates an IAM role for Lambda function execution with configurable policies.
 * This module uses terraform-aws-modules/terraform-aws-iam/aws//modules/iam-assumable-role
 */

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Use the terraform-aws-modules IAM assumable role module
module "lambda_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  # Role configuration
  role_name         = var.role_name
  role_description  = var.role_description
  create_role       = true

  # Trust policy - allow Lambda service to assume this role
  trusted_role_services = ["lambda.amazonaws.com"]

  # Managed policy ARNs to attach
  custom_role_policy_arns = var.managed_policy_arns

  # Additional inline policies (if needed)
  role_requires_mfa = false

  # Tags
  tags = merge(
    var.tags,
    {
      Name        = var.role_name
      Component   = "iam-lambda-role"
      ManagedBy   = "polaris-stack"
    }
  )
}

# Additional inline policy for Lambda execution (if custom policies are needed)
resource "aws_iam_role_policy" "lambda_execution_policy" {
  count = var.custom_policy_json != null ? 1 : 0

  name   = "${var.role_name}-execution-policy"
  role   = module.lambda_execution_role.iam_role_id
  policy = var.custom_policy_json
}
