variable "s3_bucket_id" {
  description = "ID (name) of the S3 bucket (from S3 module output)"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket (from S3 module output)"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function (from Lambda module output)"
  type        = string
}

variable "s3_events" {
  description = "List of S3 event types to trigger Lambda (e.g., s3:ObjectCreated:*)"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "filter_prefix" {
  description = "Prefix filter for S3 objects (optional)"
  type        = string
  default     = null
}

variable "filter_suffix" {
  description = "Suffix filter for S3 objects (optional, e.g., .json, .txt)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags (not directly used but kept for consistency)"
  type        = map(string)
  default     = {}
}
