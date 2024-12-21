output "lambda" {
  value       = aws_lambda_function.lambda
  description = "This returns the entire lambda function object with it's dozens or so attributes. See readme for link to that."
}

output "lambda_role_arn" {
  value       = local.lambda_role_arn
  description = "ARN of IAM Role attached to this Lambda"
}

output "lambda_log_group_name" {
  value       = local.log_group_name
  description = "Lambda Cloudwatch Log Group Name"
}

output "alias" {
  value       = aws_lambda_alias.default
  description = "The propertoes of the lambda alias"
}