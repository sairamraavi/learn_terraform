resource "aws_instance" "this" {
  region                 = var.aws_region
  ami                    = data.aws_ami.ubuntu.id
  availability_zone      = var.availability_zone
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
}
