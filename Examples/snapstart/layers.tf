resource "aws_lambda_layer_version" "layer" {
  layer_name               = "pandas"
  description              = "pandas and openpyxl"
  compatible_runtimes      = ["python3.11"]
  compatible_architectures = ["arm64"]
  filename                 = local.filename
  source_code_hash         = filebase64sha256(local.filename)
  skip_destroy             = false
}