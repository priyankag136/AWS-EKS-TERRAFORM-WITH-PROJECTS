resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "mywebapp_bucket" {
  bucket = "myrosestore-bucket2-${random_id.rand_id.hex}"
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.mywebapp_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mywebapp_policy" {
  bucket = aws_s3_bucket.mywebapp_bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject",
          Effect    = "Allow",
          Principal = "*",
          Action    = "s3:GetObject",
          Resource  = "${aws_s3_bucket.mywebapp_bucket.arn}/*"
        }
      ]
    }
  )
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

resource "aws_s3_bucket_website_configuration" "mywebapp_web_config" {
  bucket = aws_s3_bucket.mywebapp_bucket.id

  index_document {
    suffix = "index.html"
  }
}


resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.mywebapp_bucket.bucket
  source       = "${path.module}/index.html"
  key          = "index.html"
  content_type = "text/html"
 
 depends_on = [aws_s3_bucket_policy.mywebapp_policy] 
}
/*
resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.mywebapp-bucket.bucket
  source       = "./styles.css"
  key          = "styles.css"
  content_type = "text/css"
}

locals {
  image_files = {
    "image-01.jpg" = "C:\\Users\\Priyanka Gangawane\\Desktop\\MyWebsite\\images\\image-01.jpg"
    "image-02.jpg" = "C:\\Users\\Priyanka Gangawane\\Desktop\\MyWebsite\\images\\image-02.jpg"
    "image-03.jpg" = "C:\\Users\\Priyanka Gangawane\\Desktop\\MyWebsite\\images\\image-03.jpg"
  }
}

resource "aws_s3_object" "images" {
  for_each = local.image_files

  bucket = aws_s3_bucket.mywebapp-bucket.bucket
  key    = "images/${each.key}"
  source = each.value
  etag   = filemd5(each.value)
}*/

resource "aws_s3_object" "images" {
  for_each = fileset("${path.module}/files/images", "*")

  bucket = aws_s3_bucket.mywebapp_bucket.bucket
  key    = "images/${each.value}"
  source = "${path.module}/files/images/${each.value}"
  etag   = filemd5("${path.module}/files/images/${each.value}")

  depends_on = [aws_s3_bucket_policy.mywebapp_policy]
}


output "bucket_id" {
  value = aws_s3_bucket.mywebapp_bucket.id
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.mywebapp_web_config.website_endpoint
}