provider "aws" {
  region = "us-east-1"
}
#s



resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "myapp-network" {
    source = "./modules/Network"
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}




resource "aws_route_table_association" "myapp-rt-association" {
    subnet_id = module.myapp-network.subnet.id
    route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}



module "myapp-server" {
    source = "./modules/EC2"
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
    pub_key_location = var.pub_key_location
    subnet_id = module.myapp-network.subnet.id
    instance_type = var.instance_type
    image_name = var.image_name
}