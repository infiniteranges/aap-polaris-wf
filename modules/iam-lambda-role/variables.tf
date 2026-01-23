variable "role_name" {
  description = "Name of the IAM role for Lambda execution"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role for Lambda function execution"
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_policy_json" {
  description = "JSON string for custom inline policy (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
