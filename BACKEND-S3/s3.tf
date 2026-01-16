resource "aws_s3_bucket" "remote_s3" {
  bucket = "backend-s3-state-bucket"
  tags = {
    Name = "backend-s3-state-bucket"
  }
}