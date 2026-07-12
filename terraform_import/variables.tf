variable "aws_region" {
  description = "aws region in which resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Aws S3 bucket name to create"
  type        = string
  default     = "tf-application-data-bucket"
}

variable "sample_bucket_name" {
  description = "Name of the sample S3 bucket to import"
  type        = string
  default     = "sairam-another-sse-s3-bucket"
}

variable "project_name" {
  description = "Project name for which resources will be created"
  type        = string
  default     = "xcorp"
}
