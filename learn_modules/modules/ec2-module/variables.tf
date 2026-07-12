variable "aws_region" {
  description = "The AWS region to deploy the EC2 instance"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "availability_zone" {
  description = "The availability zone for the EC2 instance"
  type        = string
  default     = "ap-south-1a"
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "The security group IDs for the EC2 instance"
  type        = list(string)
}