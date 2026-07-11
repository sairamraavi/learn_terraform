resource "aws_s3_bucket" "application_data_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.bucket_name}-data-bucket"
    Environment = "Dev"
  }
}