provider "aws" {
  region = "ap-south-1"
}

variable "env_prefix" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "subnet_cidr_block" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "avail_zone" {

}

variable "environment" {
  description = "deplyment environment"
  default     = "development"
  type        = string
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}
resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet-1",
    "vpc-env" : var.environment
  }
}

# resource "aws_route_table" "dev_route_table" {
#   vpc_id = aws_vpc.dev_vpc.id
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.dev_internet_gateway.id
#     }

#     tags = {
#       "Name" = "${var.env_prefix}-rtb"
#     }
# }

resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    "Name" = "${var.env_prefix}-igtw"
  }
}

# resource "aws_route_table_association" "dev_route_table_assc" {
#     subnet_id = aws_subnet.dev-subnet-1.id
#     route_table_id = aws_route_table.dev_route_table.id
# }

resource "aws_default_route_table" "dev_default_route_table" {
  default_route_table_id = aws_vpc.dev_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_internet_gateway.id
  }

  tags = {
    "Name" : "${var.env_prefix}-default_route_table"
  }
}

resource "aws_security_group" "dev_sg" {
  name   = "dev_sg"
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    "Name" = "${var.env_prefix}-security-group"
  }

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    self             = false
    description      = "Outgoing"
    from_port        = 0
    prefix_list_ids  = []
    protocol         = "-1"
    to_port          = 0
  }]

  ingress = [{
    cidr_blocks      = [var.my_ip] #ips allowed to access the ports defined
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
    description      = "Incoming SSH"
    self             = false
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 8080
    protocol         = "tcp"
    to_port          = 8080
    description      = "Incoming Browser"
    self             = false
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    }
  ]
}

# Fetch amazon linux ami id
data "aws_ami"   "latest_amazon_linux_image" {
    most_recent = true
    owners = []
    
}

resource "aws_instance" "dev_server" {
  ami = "ami-00bf4ae5a7909786c"
}

output "dev-vpc-id" {
  value = aws_vpc.dev_vpc.id
}

output "dev-subnet-1-id" {
  value = aws_subnet.dev-subnet-1.id
}
