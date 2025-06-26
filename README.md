# Terraform AWS EC2 + VPC Project

This Terraform project provisions a basic AWS infrastructure including a VPC, subnet, internet gateway, route table, security group, EC2 instance (with Docker and Nginx), and all necessary networking components. Below is a detailed explanation of each block and how to use this project.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [How to Use](#how-to-use)
- [Terraform Blocks Explained](#terraform-blocks-explained)
  - [Provider Block](#provider-block)
  - [Variables](#variables)
  - [VPC](#vpc)
  - [Subnet](#subnet)
  - [Internet Gateway](#internet-gateway)
  - [Route Table & Association](#route-table--association)
  - [Default Route Table](#default-route-table)
  - [Security Group](#security-group)
  - [AMI Data Source](#ami-data-source)
  - [Key Pair](#key-pair)
  - [EC2 Instance](#ec2-instance)
  - [Outputs](#outputs)
- [Customizing](#customizing)
- [Cleanup](#cleanup)

---

## Project Overview
This project automates the creation of a simple AWS environment suitable for running a Dockerized Nginx web server. It includes:
- A custom VPC and subnet
- Internet access via an Internet Gateway
- Routing and security configuration
- An EC2 instance with Docker and Nginx

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed
- An AWS account and credentials configured (via `aws configure` or environment variables)
- An existing SSH public key (for EC2 access)

## Project Structure
```
terraform/
  main.tf            # Main Terraform configuration
  providers.tf       # Provider and Terraform version
  terraform.tfvars   # Variable values
```

## How to Use
1. **Clone the repository and navigate to the `terraform/` directory.**
2. **Edit `terraform.tfvars`** to set your desired values (VPC CIDR, subnet, key path, etc).
3. **Initialize Terraform:**
   ```sh
   terraform init
   ```
4. **Preview the plan:**
   ```sh
   terraform plan
   ```
5. **Apply the configuration:**
   ```sh
   terraform apply
   ```
6. **After apply, Terraform will output the AMI ID and the public IP of your EC2 instance.**

---

## Terraform Blocks Explained

### Provider Block
```
provider "aws" {
  region = "us-east-1"
}
```
- Configures Terraform to use the AWS provider in the `us-east-1` region.

### Variables
```
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "pub_key_location" {}
```
- These variables allow you to customize the VPC, subnet, EC2 instance, and SSH key. Values are set in `terraform.tfvars`.

### VPC
```
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = { Name = "${var.env_prefix}-vpc" }
}
```
- Creates a Virtual Private Cloud (VPC) with the specified CIDR block and a name tag.

### Subnet
```
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = { Name = "${var.env_prefix}-subnet-1" }
}
```
- Creates a subnet within the VPC, in the specified availability zone.

### Internet Gateway
```
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = { Name = "${var.env_prefix}-igw" }
}
```
- Attaches an Internet Gateway to the VPC, enabling internet access.

### Route Table & Association
```
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { Name = "${var.env_prefix}-route-table" }
}

resource "aws_route_table_association" "myapp-rt-association" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}
```
- Creates a route table with a default route to the internet and associates it with the subnet.

### Default Route Table
```
resource "aws_default_route_table" "myapp-default-rt" {
  default_route_table_id = aws_route_table.myapp-route-table.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { Name = "${var.env_prefix}-rtb" }
}
```
- Ensures the default route table for the VPC routes all outbound traffic to the internet.

### Security Group
```
resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  description = "Security group for myapp"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress { ... } # SSH (22), HTTP (8080), HTTPS (443)
  egress { ... }  # All outbound
  tags = { Name = "${var.env_prefix}-sg" }
}
```
- Allows inbound SSH (22), HTTP (8080), and HTTPS (443) from anywhere. All outbound traffic is allowed.

### AMI Data Source
```
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter { name = "name"; values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}
```
- Fetches the latest Amazon Linux 2 AMI for use by the EC2 instance.

### Key Pair
```
resource "aws_key_pair" "server-key" {
  key_name = "server-key"
  public_key = file(var.pub_key_location)
}
```
- Uploads your local SSH public key to AWS for EC2 access.

### EC2 Instance
```
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  security_groups = [aws_security_group.myapp-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.server-key.key_name
  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y && sudo yum install -y docker
    sudo systemctl start docker
    sudo usermod -a -G docker ec2-user
    sudo systemctl enable docker
    docker run -p 8080:80 -d nginx
  EOF
  tags = { Name = "${var.env_prefix}-server" }
}
```
- Provisions an EC2 instance:
  - Uses the latest Amazon Linux 2 AMI
  - Instance type as specified
  - In the created subnet and security group
  - Public IP for internet access
  - Installs Docker and runs an Nginx container (port 8080)

### Outputs
```
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}
output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}
```
- After apply, shows the AMI ID used and the public IP of the EC2 instance.

---

## Customizing
- Edit `terraform.tfvars` to change VPC/subnet CIDRs, instance type, environment prefix, or SSH key location.
- Modify security group rules in `main.tf` to restrict/expand access.

## Cleanup
To destroy all resources created by this project:
```sh
terraform destroy
```

---

## Notes
- Make sure your AWS credentials are set up before running Terraform.
- The EC2 instance will be accessible via SSH (port 22) and HTTP (port 8080) using the public IP output.
- The Nginx server will be available at `http://<ec2_public_ip>:8080`. 