terraform {
  backend "s3" {
    bucket         = "320628010995-terraform-tfstate"
    key            = "lab1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
  }
}