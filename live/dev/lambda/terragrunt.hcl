# Lambda Function - Terragrunt Configuration
# Depends on: IAM role

terraform {
  source = "../../../modules/lambda-function"
}

# Include root config for shared remote_state
include {
  path = find_in_parent_folders()
}

# Dependencies - Terragrunt will wait for IAM role to complete
dependencies {
  paths = ["../iam"]
}

# Get IAM role ARN from dependency
dependency "iam" {
  config_path = "../iam"
  
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::123456789012:role/mock-lambda-role"
  }
  
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Inputs for Lambda function module
inputs = {
  function_name = "${get_env("LAMBDA_NAME", "event-processor")}-${get_env("ENVIRONMENT", "dev")}"
  description   = "Lambda function for processing S3 events - Polaris Event-Driven Stack"
  handler       = get_env("LAMBDA_HANDLER", "index.handler")
  runtime       = get_env("LAMBDA_RUNTIME", "python3.11")
  timeout       = tonumber(get_env("LAMBDA_TIMEOUT", "30"))
  memory_size   = tonumber(get_env("LAMBDA_MEMORY", "128"))
  
  # Use IAM role from dependency (no hardcoded ARNs)
  iam_role_arn = dependency.iam.outputs.iam_role_arn
  
  # Source code path (will be provided by Polaris/AAP)
  source_path = get_env("LAMBDA_SOURCE_PATH", null)
  s3_bucket   = get_env("LAMBDA_S3_BUCKET", null)
  s3_key      = get_env("LAMBDA_S3_KEY", null)
  
  environment_variables = {
    ENVIRONMENT = get_env("ENVIRONMENT", "dev")
    STACK_TYPE  = "aws-event-driven-s3-lambda"
    DEPLOYMENT_ID = get_env("DEPLOYMENT_ID", "unknown")
  }
  
  tags = {
    Environment = get_env("ENVIRONMENT", "dev")
    StackType   = "aws-event-driven-s3-lambda"
    DeploymentId = get_env("DEPLOYMENT_ID", "unknown")
    ManagedBy   = "polaris-stack"
  }
}
