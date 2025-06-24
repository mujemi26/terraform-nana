provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev-team" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "dev-team"
  }
}

resource "aws_subnet" "dev-team-subnet1" {
  vpc_id = aws_vpc.dev-team.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-team-subnet1"
  }
}

resource "aws_subnet" "dev-team-subnet2" {
  vpc_id = aws_vpc.dev-team.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "dev-team-subnet2"
  }
}
