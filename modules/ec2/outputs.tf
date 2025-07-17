output "public_ec2_instance" {
    value = aws_instance.centos_instance[0].id
}