provider "aws" {
    region = "ap-south-1"
}

variable "subnet_cidr_block" {
    description = "subnet cidr block"
    default = "10.0.48.0/24"
    type = string
}

variable "subnet_cidr_blocks" {
    description = "subnet cidr blocks"
    type = list(object({
        name = string
        cidr_block = string
    }))
}

variable "environment" {
  description = "deplyment environment"
  default = "development"
  type = string
}

resource "aws_vpc" "dev_vpc" {
    cidr_block = var.subnet_cidr_blocks[0].cidr_block
    tags = {
        Name: var.subnet_cidr_blocks[0].name
    }
}



resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.subnet_cidr_blocks[1].cidr_block
    availability_zone = "ap-south-1a"
    tags = {
      "Name" = var.subnet_cidr_blocks[1].name,
      "vpc-env": var.environment
    }
}

# Will be deleted
# data "aws_vpc" "existing_vpc" {
#     default = true
# }

# resource "aws_subnet" "dev-subnet-2" {
#     vpc_id = data.aws_vpc.existing_vpc.id
#     cidr_block = "172.31.48.0/20"
#     tags = {
#       "Name" = "subnet-2-default"
#     }
#     availability_zone = "ap-south-1a"
# }

output "dev-vpc-id" {
    value = aws_vpc.dev_vpc.id
}

output "dev-subnet-1-id" {
  value = aws_subnet.dev-subnet-1.id
}