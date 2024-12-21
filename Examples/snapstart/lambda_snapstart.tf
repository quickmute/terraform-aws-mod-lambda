module "snapstart_lambda" {
  source = "../.."

  lambda_name                       = "${local.random_petname}-snappy"
  lambda_filename                   = local.lambda_filename
  lambda_handler                    = "lambda_function.lambda_handler"
  lambda_runtime                    = "python3.11"
  create_role                       = false
  role_arn                          = local.role_arn
  xray_enabled                      = true
  enable_async_invoke_configuration = true
  async_invoke_configuration = {
    on_success = aws_sns_topic.target.arn
    on_failure = aws_sns_topic.target.arn
  }
  lambda_layer_arns = local.layer_arns
  lambda_environment_variables = {
    test1 = "test2"
  }
  reserved_concurrent_executions = 1
  lambda_timeout                 = 30
  snapstart_enabled              = true
  tags                           = local.tags
}

resource "aws_lambda_permission" "snapstart_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = module.snapstart_lambda.lambda.function_name
  principal     = "sns.amazonaws.com"
  statement_id  = "AllowExecutionFromSNS"
  source_arn    = aws_sns_topic.source.arn
}

resource "aws_lambda_permission" "snapstart_lambda_alias" {
  action        = "lambda:InvokeFunction"
  function_name = module.snapstart_lambda.lambda.function_name
  principal     = "sns.amazonaws.com"
  statement_id  = "AllowExecutionFromSNS"
  source_arn    = aws_sns_topic.source.arn
  qualifier     = module.snapstart_lambda.alias.name
}