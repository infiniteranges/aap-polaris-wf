variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "Lambda function created by Polaris stack"
}

variable "handler" {
  description = "Lambda function handler (e.g., index.handler)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime (e.g., python3.11, nodejs18.x)"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for Lambda execution (from IAM module output)"
  type        = string
}

variable "source_path" {
  description = "Path to the Lambda function source code file (creates zip)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key (path) to the Lambda deployment package"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs (optional, for VPC-enabled Lambda)"
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs (optional, for VPC-enabled Lambda)"
  type        = list(string)
  default     = null
}

variable "dead_letter_queue_arn" {
  description = "ARN of the dead letter queue (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}
