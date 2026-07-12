resource "aws_s3_bucket" "application_data_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.bucket_name}-data-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "sample_bucket_sairam" {
  bucket = var.sample_bucket_name

  tags = {
    Name        = "${var.sample_bucket_name}-sample-bucket"
    Environment = "Dev"
  }
}