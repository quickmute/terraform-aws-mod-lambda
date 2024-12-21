resource "aws_cloudwatch_log_group" "default" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  tags              = merge(local.tags, { Name = local.log_group_name})
}

