resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name = "Backend-s3-state-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Backend-s3-state-table"
  }
}