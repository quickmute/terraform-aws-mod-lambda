## Automatically assign the latest version to the alias
resource "aws_lambda_alias" "default" {
  name             = var.alias
  description      = var.alias_description
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
}

## Create a duplicate invoke config that is tied to alias
resource "aws_lambda_function_event_invoke_config" "alias" {
  count         = var.enable_async_invoke_configuration ? 1 : 0
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = aws_lambda_alias.default.name

  dynamic "destination_config" {
    for_each = var.async_invoke_configuration.on_failure != null || var.async_invoke_configuration.on_success != null ? [1] : []
    content {
      dynamic "on_failure" {
        for_each = var.async_invoke_configuration.on_failure != null ? [1] : []
        content {
          destination = var.async_invoke_configuration.on_failure
        }
      }
      dynamic "on_success" {
        for_each = var.async_invoke_configuration.on_success != null ? [1] : []
        content {
          destination = var.async_invoke_configuration.on_success
        }

      }
    }
  }
  maximum_event_age_in_seconds = var.async_invoke_configuration.maximum_event_age_in_seconds
  maximum_retry_attempts       = var.async_invoke_configuration.maximum_retry_attempts
}