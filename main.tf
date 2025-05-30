provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:/Users/salon/.aws/credentials"]
}

locals {
  lambda_role_arn = "arn:aws:iam::605134428663:role/lambda_role"
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  # now packaging lambda_function.py
  source_file = "${path.module}/python/hello_python.py"
  output_path = "${path.module}/python/hello_python.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = data.archive_file.zip_the_python_code.output_path
  function_name    = "Jhooq-Lambda-Function"
  role             = local.lambda_role_arn  

  # handler must match module.function
  handler          = "hello_python.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256

  # ensure Terraform always re-uploads when code changes
  lifecycle {
    create_before_destroy = true
  }
}

output "lambda_role_arn" {
  value = local.lambda_role_arn
}

