# Root Terragrunt Configuration
# Shared configuration for all modules in this environment
# This file is included by child modules via find_in_parent_folders()

# Remote state configuration (shared across all modules)
remote_state {
  backend = get_env("TF_STATE_BACKEND", "s3")
  
  config = {
    # S3 backend configuration
    bucket         = get_env("TF_STATE_BUCKET", "polaris-terraform-state")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("AWS_REGION", "us-east-1")
    encrypt        = true
    dynamodb_table = get_env("TF_STATE_LOCK_TABLE", "terraform-locks")
    
    # For local backend (development/testing)
    # backend = "local"
    # path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}

# Common inputs for all modules (merged with module-specific inputs)
inputs = {
  # Common tags
  tags = {
    Environment = get_env("ENVIRONMENT", "dev")
    ManagedBy   = "polaris-stack"
    StackType   = "aws-event-driven-s3-lambda"
    DeploymentId = get_env("DEPLOYMENT_ID", "unknown")
  }
  
  # AWS region (can be overridden per module)
  region = get_env("AWS_REGION", "us-east-1")
}
