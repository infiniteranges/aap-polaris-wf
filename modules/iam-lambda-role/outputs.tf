output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = module.lambda_execution_role.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = module.lambda_execution_role.iam_role_name
}

output "iam_role_id" {
  description = "ID of the IAM role"
  value       = module.lambda_execution_role.iam_role_id
}
