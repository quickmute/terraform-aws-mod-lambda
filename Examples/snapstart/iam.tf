resource "aws_iam_role" "example" {
  name               = local.random_petname
  description        = "Example Lambda role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "sns" {
  role   = aws_iam_role.example.id
  name   = "sns_all"
  policy = data.aws_iam_policy_document.sns_all.json
}

resource "aws_iam_role_policy" "cw" {
  role   = aws_iam_role.example.id
  name   = "cw"
  policy = data.aws_iam_policy_document.cw.json
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_all" {
  statement {
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.target.arn]
  }
}

data "aws_iam_policy_document" "cw" {
  statement {
    actions = [
      "logs:*"
    ]
    resources = ["*"]
  }
}