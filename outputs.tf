output "aws_ami_id" {
    value = module.myapp-server.ami_id
}

output "ec2_public_ip" {
    value = module.myapp-server.instance_public_ip
}

output "vpc_id" {
    value = aws_vpc.myapp-vpc.id
}

output "subnet_id" {
    value = module.myapp-network.subnet.id
}

output "security_group_id" {
    value = module.myapp-server.security_group_id
}