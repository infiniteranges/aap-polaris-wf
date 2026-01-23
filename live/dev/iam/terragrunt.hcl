# IAM Lambda Execution Role - Terragrunt Configuration
# This is the first component in the stack (no dependencies)

terraform {
  source = "../../../modules/iam-lambda-role"
}

# Include root config for shared remote_state
include {
  path = find_in_parent_folders()
}

# Inputs for IAM role module
inputs = {
  role_name = "polaris-lambda-execution-role-${get_env("ENVIRONMENT", "dev")}"
  role_description = "IAM role for Lambda function execution - Polaris Event-Driven Stack"
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  tags = {
    Environment = get_env("ENVIRONMENT", "dev")
    StackType   = "aws-event-driven-s3-lambda"
    DeploymentId = get_env("DEPLOYMENT_ID", "unknown")
    ManagedBy   = "polaris-stack"
  }
}
