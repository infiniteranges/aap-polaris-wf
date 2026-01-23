/**
 * S3 Bucket Module
 * 
 * Creates an AWS S3 bucket with configurable versioning, encryption, and lifecycle policies.
 * This module uses terraform-aws-modules/terraform-aws-s3-bucket
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

# Use the terraform-aws-modules S3 bucket module
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = var.bucket_name
  acl    = var.acl

  # Versioning
  versioning = {
    enabled    = var.versioning_enabled
    mfa_delete = var.versioning_mfa_delete
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = var.encryption_algorithm
        kms_master_key_id = var.kms_key_id
      }
      bucket_key_enabled = var.bucket_key_enabled
    }
  }

  # Public access block
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  # Lifecycle rules
  lifecycle_rule = var.lifecycle_rules

  # CORS configuration
  cors_rule = var.cors_rules

  # Tags
  tags = merge(
    var.tags,
    {
      Name      = var.bucket_name
      Component = "s3-bucket"
      ManagedBy = "polaris-stack"
    }
  )
}
