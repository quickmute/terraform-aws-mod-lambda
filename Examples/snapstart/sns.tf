resource "aws_sns_topic" "target" {
  name = "${local.random_petname}-target"
  tags = local.tags
}

resource "aws_sns_topic" "source" {
  name = "${local.random_petname}-source"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "latest" {
  topic_arn = aws_sns_topic.source.arn
  protocol  = "lambda"
  endpoint  = module.snapstart_lambda.lambda.arn
}

resource "aws_sns_topic_subscription" "alias" {
  topic_arn = aws_sns_topic.source.arn
  protocol  = "lambda"
  endpoint  = module.snapstart_lambda.alias.arn
}