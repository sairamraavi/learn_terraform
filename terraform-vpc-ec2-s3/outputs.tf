output "vpc_id" {
  value = aws_vpc.my_vpc.id
}
output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
output "ec2_instance_id" {
  value = aws_instance.web.id
}
output "ec2_instance_public_ip" {
  value = aws_instance.web.public_ip
}
