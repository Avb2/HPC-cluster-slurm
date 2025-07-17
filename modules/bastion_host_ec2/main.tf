locals {
    ami_id = "ami-0150ccaf51ab55a51"
    instance_type = "t2.micro"
    key_name = "asmt1"
    az = "us-east-1a"
}



### Allows access from my IP on SSH
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH traffic from my machine"
  vpc_id      = var.vpc

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["47.36.45.70/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}



### Creates an Amazon Linux EC2 Instance
resource "aws_instance" "linux_instance" {
    ami = local.ami_id
    instance_type = local.instance_type
    key_name = local.key_name
    subnet_id = var.pub_sub 
    associate_public_ip_address = true


    availability_zone = local.az

    vpc_security_group_ids = [
        aws_security_group.bastion_sg.id
    ] 

    tags = {
        Name = "Bastion"
    }
}


