resource "aws_iam_role" "iam_role" {
  count              = var.create_role ? 1 : 0
  name               = local.new_lambda_role_name
  description        = "Lambda IAM Role used by ${local.new_lambda_role_name}"
  assume_role_policy = data.aws_iam_policy_document.iam_trust_policy_doc.json
  tags = merge(
    var.tags,
    {
      Name = local.new_lambda_role_name
    }
  )
}

# Attach pre-defined policies to our new role
resource "aws_iam_role_policy_attachment" "attachment" {
  for_each   = var.create_role ? var.role_policy_arns : {}
  role       = one(aws_iam_role.iam_role[*].id)
  policy_arn = each.value
}

# Build inline policies for our new role
resource "aws_iam_role_policy" "policy" {
  for_each = var.create_role ? local.role_inline_policies : {}
  role     = one(aws_iam_role.iam_role[*].id)
  name     = each.key
  policy   = each.value
}

## This is standard for Lambda function.
## The attached IAM role needs to have TRUST RELATIONSHIP to lambda.amazonaws.com IdP. 
## This can be seen in the "Trust Relationship" tab of the IAM role. 
data "aws_iam_policy_document" "iam_trust_policy_doc" {
  source_policy_documents = [var.role_assume_role_policy_document_json]
  statement {
    sid     = "baseRoleAssumptionLambdaService"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}


###############################################################################
## 
## Policy to put Lambda inside VPC 
##
###############################################################################
data "aws_iam_policy_document" "lambda_vpc_access_policy_document" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }
}

###############################################################################
## 
## Policy to use X-Ray
##
###############################################################################
data "aws_iam_policy_document" "xray_policy_document" {
  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }
}

###############################################################################
## 
## Policy to let Lambda write to CW Logs
##
###############################################################################
data "aws_iam_policy_document" "lambda_cloudwatch_logs_policy_document" {
  statement {
    sid = "CwLogging"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}:*"
    ]

    effect = "Allow"
  }

  statement {
    sid = "CwDescribeLogGroups"

    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }
}

###############################################################################
## 
## Policy for destinations
##
###############################################################################
data "aws_iam_policy_document" "lambda_destination_policy_document" {
  dynamic "statement" {
    for_each = local.invoke_destinations_map
    content {
      actions   = statement.value["properties"]["actions"]
      resources = [statement.key]
      effect    = "Allow"
    }
  }
}