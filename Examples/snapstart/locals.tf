locals {
  tags = {
    Name        = local.random_petname
    Developer   = "Bugs Bunny"
    Description = "Example from Lambda"
  }
}

locals {
  filename = "${path.module}/pandas/layer.zip"
}

locals {
  random_petname = random_pet.lambda.id
}

locals {
  lambda_filename = data.archive_file.default_lambda_code.output_path
  role_arn        = aws_iam_role.example.arn
  layer_arns      = [aws_lambda_layer_version.layer.arn]
}