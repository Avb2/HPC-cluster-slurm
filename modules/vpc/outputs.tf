output "vpc_id" {
    value = aws_vpc.main.id
}


output "pub_sub" {
    value = aws_subnet.subnet[1].id
}


output "priv_sub" {
    value = aws_subnet.subnet[0].id
}

