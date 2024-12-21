provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

data "archive_file" "default_lambda_code" {
  type        = "zip"
  source_file = "./files/lambda_function.py"
  output_path = "./files/example.zip"
}

resource "random_pet" "lambda" {
  length = 1
}

locals {
  lambda_name = "lambda-${random_pet.lambda.id}"
}

module "example" {
  source = "../.."

  lambda_name                       = local.lambda_name
  lambda_filename                   = "${path.module}/files/example.zip"
  lambda_handler                    = "lambda_function.lambda_handler"
  lambda_runtime                    = "python3.12"
  lambda_environment_variables = {
    test1 = "test2"
  }
  reserved_concurrent_executions = 1
  lambda_timeout                 = 30

  tags = {
    Developer = "Bugs Bunny",
  }
}

resource "aws_sns_topic" "example" {
  name = local.lambda_name
}

output "version" {
  value = module.example.lambda
}