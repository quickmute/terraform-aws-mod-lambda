data "archive_file" "default_lambda_code" {
  type        = "zip"
  source_file = "${path.module}/lambdafiles/lambda_function.py"
  output_path = "${path.module}/lambdafiles/example.zip"
}

