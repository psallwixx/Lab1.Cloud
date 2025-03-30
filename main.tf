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