locals {
  ## When using ECR image then package is URI, else it is ZIP
  package_type = var.lambda_image_uri == null ? "Zip" : "Image"
  ## name of lambda function
  lambda_function_name = join("_", compact([var.name_prefix, var.lambda_name]))
  ## determine source code hash but only if filename is present
  ## if this changes then it'll trigger an update. Be sure to use BASE64 SHA256 type hash
  #source_code_hash = var.lambda_image_uri == null ? null : var.lambda_filename == null ? filebase64sha256(var.lambda_s3_key) : filebase64sha256(var.lambda_filename)
  source_code_hash = var.lambda_image_uri != null ? null : var.lambda_filename == null ? null : filebase64sha256(var.lambda_filename)
  ## name of the log group
  log_group_name = "/aws/lambda/${local.lambda_function_name}"
  ## name of the new role for lambda function
  new_lambda_role_name = join("_", [local.lambda_function_name, "role"])
  ## actual object that will be the lambda role
  ## Wrap one() function incase the content within is empty. This may be experienced if you run into partial destroy due to error such as resource in wrong state
  lambda_role_arn = one(aws_iam_role.iam_role[*].id) == null ? var.role_arn : aws_iam_role.iam_role[0].arn
  ##just your typical tag, nothing to see here
  tags = merge(var.tags,
    {
      "TFModule" = basename(path.module),
      "VPC"      = title(tostring(var.vpc_enabled))
    }
  )
}

## If lambda_image_uri then we can turn these off
locals {
  handler = var.lambda_image_uri == null ? var.lambda_handler : null
  runtime = var.lambda_image_uri == null ? var.lambda_runtime : null
  layers  = var.lambda_image_uri == null ? var.lambda_layer_arns : null
}

## locals for ECR image stuff
locals {
  image_command           = lookup(var.lambda_image_config, "command", [""])
  image_entry_point       = lookup(var.lambda_image_config, "entry_point", [""])
  image_working_directory = lookup(var.lambda_image_config, "working_directory", "")
}

## Locals for determining if any destination inline policy needs to be added
locals {
  ## Use this local as a lookup table on destinations supported and how we should build our policy
  destination_types = {
    "arn:aws:sns" = {
      "type"       = "sns",
      "startswith" = "arn:aws:sns",
      "actions"    = ["sns:Publish"]
    },
    "arn:aws:events" = {
      "type"       = "events",
      "startswith" = "arn:aws:events",
      "actions"    = ["events:PutEvents"]
    },
    "arn:aws:sqs" = {
      "type"       = "sqs",
      "startswith" = "arn:aws:sqs",
      "actions"    = ["sqs:SendMessage"]
    },
    "arn:aws:lambda" = {
      "type"       = "lambda",
      "startswith" = "arn:aws:lambda",
      "actions"    = ["lambda:InvokeFunction"]
    },
  }

  ## Create a list of destination ARNs, if both on_fail and on_success point to same ARN, this'll result in single item
  invoke_destinations_list = distinct(compact([
    var.async_invoke_configuration.on_failure,
    var.async_invoke_configuration.on_success,
  ]))

  ## NOW using two locals above, we create a map that contains both information
  invoke_destinations_map = {
    for key in local.invoke_destinations_list :
    key => {
      for key2, value2 in local.destination_types :
      "properties" => value2
      if startswith(key, key2)
    }
  }
}

locals {
  role_inline_policies = merge(
    var.role_inline_policies,
    var.vpc_enabled ? { "lambda_vpc_access" = data.aws_iam_policy_document.lambda_vpc_access_policy_document.json } : {},
    var.xray_enabled ? { "lambda_xray" = data.aws_iam_policy_document.xray_policy_document.json } : {},
    length(local.invoke_destinations_list) > 0 ? { "destination_access" = data.aws_iam_policy_document.lambda_destination_policy_document.json } : {},
    { "lambda_logging" = data.aws_iam_policy_document.lambda_cloudwatch_logs_policy_document.json }
  )
}