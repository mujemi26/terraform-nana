provider "aws" {
  region = "us-east-1"
}
#variables

variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "availability_zone" {}

variable "env_prefix" {}

variable "instance_type" {}

variable "pub_key_location" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}


resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-route-table"
    }
}

resource "aws_route_table_association" "myapp-rt-association" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_default_route_table" "myapp-default-rt" {
    default_route_table_id = aws_route_table.myapp-route-table.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    description = "Security group for myapp"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "server-key" {
    key_name = "server-key"
    public_key = file(var.pub_key_location)
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.myapp-subnet-1.id
    security_groups = [aws_security_group.myapp-sg.id]
    availability_zone = var.availability_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.server-key.key_name
    tags = {
        Name = "${var.env_prefix}-server"
    }
}






output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}