provider "aws" {
  region = "eu-central-1"
}

module "labels" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = {
    enabled             = true
    namespace           = "lab_1" 
    environment         = "dev"
    stage               = "dev"        
    name                = "courses"
    delimiter           = "-"
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    label_order         = ["namespace", "environment", "stage", "name", "attributes"]
    regex_replace_chars = "/[^a-zA-Z0-9-]/"
    id_length_limit     = 0
  }
}

resource "aws_dynamodb_table" "courses" {
  name         = module.labels.id
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = module.labels.id
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = "dynamodb:Scan"
        Resource = aws_dynamodb_table.courses.arn
      }
    ]
  })
}

resource "aws_lambda_function" "get_all_courses" {
  function_name = "${module.labels.id}-get-all-courses"
  handler       = "get-all-courses.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda/get-all-courses.zip"
}