output "lambda_permission_id" {
  description = "ID of the Lambda permission resource"
  value       = aws_lambda_permission.allow_s3.id
}

output "s3_notification_id" {
  description = "ID of the S3 bucket notification resource"
  value       = aws_s3_bucket_notification.lambda_trigger.id
}
