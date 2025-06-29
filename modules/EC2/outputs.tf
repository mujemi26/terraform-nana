output "instance_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

output "ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "security_group_id" {
    value = aws_security_group.myapp-sg.id
}
