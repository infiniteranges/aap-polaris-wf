# S3 Lambda Notification - Terragrunt Configuration
# Depends on: S3 bucket and Lambda function

terraform {
  source = "../../../modules/s3-lambda-notification"
}

# Include root config for shared remote_state
include {
  path = find_in_parent_folders()
}

# Dependencies - Terragrunt will wait for S3 and Lambda to complete
dependencies {
  paths = ["../s3", "../lambda"]
}

# Get S3 bucket outputs from dependency
dependency "s3" {
  config_path = "../s3"
  
  mock_outputs = {
    s3_bucket_id  = "mock-bucket-name"
    s3_bucket_arn = "arn:aws:s3:::mock-bucket-name"
  }
  
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Get Lambda function outputs from dependency
dependency "lambda" {
  config_path = "../lambda"
  
  mock_outputs = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:mock-function"
  }
  
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Inputs for S3 Lambda notification module
inputs = {
  # Use outputs from dependencies (no hardcoded ARNs)
  s3_bucket_id       = dependency.s3.outputs.s3_bucket_id
  s3_bucket_arn      = dependency.s3.outputs.s3_bucket_arn
  lambda_function_arn = dependency.lambda.outputs.lambda_function_arn
  
  # S3 events to trigger Lambda
  s3_events = split(",", get_env("S3_EVENTS", "s3:ObjectCreated:*"))
  
  # Optional filters
  filter_prefix = get_env("S3_FILTER_PREFIX", null)
  filter_suffix = get_env("S3_FILTER_SUFFIX", null)
  
  tags = {
    Environment = get_env("ENVIRONMENT", "dev")
    StackType   = "aws-event-driven-s3-lambda"
    DeploymentId = get_env("DEPLOYMENT_ID", "unknown")
    ManagedBy   = "polaris-stack"
  }
}
