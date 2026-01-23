# S3 Bucket - Terragrunt Configuration
# No dependencies (can be created independently)

terraform {
  source = "../../../modules/s3-bucket"
}

# Include root config for shared remote_state
include {
  path = find_in_parent_folders()
}

# Inputs for S3 bucket module
inputs = {
  bucket_name = "${get_env("S3_BUCKET_NAME", "polaris-events")}-${get_env("ENVIRONMENT", "dev")}"
  acl         = "private"
  
  versioning_enabled = tobool(get_env("S3_VERSIONING_ENABLED", "true"))
  
  encryption_algorithm = get_env("S3_ENCRYPTION_ALGORITHM", "AES256")
  kms_key_id          = get_env("S3_KMS_KEY_ID", null)
  bucket_key_enabled  = tobool(get_env("S3_BUCKET_KEY_ENABLED", "false"))
  
  # Security: block all public access by default
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  lifecycle_rules = []
  cors_rules      = []
  
  tags = {
    Environment = get_env("ENVIRONMENT", "dev")
    StackType   = "aws-event-driven-s3-lambda"
    DeploymentId = get_env("DEPLOYMENT_ID", "unknown")
    ManagedBy   = "polaris-stack"
  }
}
