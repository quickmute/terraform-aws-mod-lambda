resource "aws_lambda_function" "lambda" {
  ## Unique name of your function
  function_name = local.lambda_function_name
  package_type  = local.package_type
  ## Name of file (be default this should be a ZIP file)
  filename = var.lambda_filename
  ## ECR image settings
  image_uri = var.lambda_image_uri
  ## deployment package, if in S3
  s3_bucket = var.lambda_s3_bucket
  s3_key    = var.lambda_s3_key
  ## This must be ARN of Role
  role = local.lambda_role_arn
  ## Architecture, this requires AWS provider 3.60.0 or higher
  architectures = var.lambda_architectures
  ## This is filename followed by main function
  handler = local.handler
  ## This is one of supported runtime
  runtime = local.runtime
  ## This is the hash of the source code
  source_code_hash = local.source_code_hash
  description      = var.lambda_description
  ## Amount of memory in MB your Lambda Function can use at runtime
  memory_size = var.lambda_memory_size
  ## Amount of time your Lambda Function has to run in seconds.
  timeout = var.lambda_timeout
  ## List of layer ARNs
  layers = local.layers
  ## arn of the KMS key used to encrypt your function's environment variables. If not provided, AWS Lambda will use a default service key.
  kms_key_arn = var.kms_key_arn
  ##The amount of reserved concurrent executions for this lambda function.
  reserved_concurrent_executions = var.reserved_concurrent_executions
  ## to publish a new version everytime we deploy
  publish = true
  ## Enable snapstart, this "PublishedVersions" is literally the only exposed option right now
  dynamic "snap_start" {
    for_each = var.snapstart_enabled ? ["PublishedVersions"] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  ## to enable xray tracing
  dynamic "tracing_config" {
    for_each = var.xray_enabled ? ["1"] : []

    content {
      mode = "Active"
    }
  }
  ## to use vpc
  dynamic "vpc_config" {
    for_each = var.vpc_enabled ? ["1"] : []

    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
  ## This is list of arguments for this function
  dynamic "environment" {
    for_each = length(keys(var.lambda_environment_variables)) > 0 ? ["1"] : []

    content {
      variables = var.lambda_environment_variables
    }
  }
  dynamic "image_config" {
    for_each = length(keys(var.lambda_image_config)) > 0 ? [1] : []

    content {
      command           = local.image_command
      entry_point       = local.image_entry_point
      working_directory = local.image_working_directory
    }
  }
  ## this is tags
  tags = merge(local.tags,
    {
      "Name"         = local.lambda_function_name
      "KeptVersions" = var.kept_versions
    }
  )
}

## Legacy invoke config that is tied to LATEST
resource "aws_lambda_function_event_invoke_config" "config" {
  count         = var.enable_async_invoke_configuration ? 1 : 0
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = "$LATEST"

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