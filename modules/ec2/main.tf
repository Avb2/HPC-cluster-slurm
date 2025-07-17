locals {
    ami_id = "ami-0e0416d387552f0b1"
    instance_type = "t2.micro"
    key_name = "asmt1"
    az = "us-east-1a"
}





resource "aws_security_group" "master_sg" {
  name        = "allow_ssh_master"
  description = "Allow SSH traffic from bastion host"
  vpc_id      = var.vpc

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [var.bastion_host_sg]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "node_sg" {
  name        = "allow_ssh_node"
  description = "Allow SSH traffic from master"
  vpc_id      = var.vpc

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.master_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}



resource "aws_instance" "centos_instance" {
    ami = local.ami_id
    instance_type = local.instance_type
    count = 3
    key_name = local.key_name
    subnet_id = var.priv_sub
    associate_public_ip_address = false


    availability_zone = local.az

    vpc_security_group_ids = [
        count.index == 0? aws_security_group.master_sg.id : aws_security_group.node_sg.id
    ] 


    user_data = <<-EOF
            #!/bin/bash
            hostname="${count.index == 0 ? "master" : "node${count.index}"}"
            hostnamectl set-hostname "$hostname"
            yum update -y

            if [ "$hostname" == "master" ]; then
                sudo dnf install epel-release -y
                sudo dnf config-manager --set-enabled crb
                sudo dnf makecache

                sudo fallocate -l 1G /swapfile
                sudo chmod 600 /swapfile
                sudo mkswap /swapfile
                sudo swapon /swapfile


                sudo dnf install -y slurm slurm-slurmctld slurm-slurmd munge


                sudo mkdir -p /etc/munge
                sudo openssl rand -out /etc/munge/munge.key -base64 1024
                sudo chown munge:munge /etc/munge/munge.key
                sudo chmod 400 /etc/munge/munge.key

                sudo dnf install ansible -y

                sudo systemctl enable munge
                sudo systemctl start munge



            else
                sudo dnf install epel-release -y
                sudo dnf config-manager --set-enabled crb
                sudo dnf makecache

                sudo fallocate -l 1G /swapfile
                sudo chmod 600 /swapfile
                sudo mkswap /swapfile
                sudo swapon /swapfile



                sudo dnf install -y slurm slurm-slurmd munge 
                
                # Manually add Munge key to workers
            fi
        EOF


    tags = {
        Name = count.index == 0? "master" : "node-${count.index}"
    }
}


