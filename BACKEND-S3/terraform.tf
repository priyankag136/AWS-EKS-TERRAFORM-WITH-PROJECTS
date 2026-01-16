terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.91.0"
    }
  }


backend "s3" {
    bucket = "backend-s3-state-bucket"
    key = "terraform.tfstate"
    region = "eu-west-3"
    #dynamodb_table = "Backend-s3-state-table"
    use_lockfile = true
  }
}
