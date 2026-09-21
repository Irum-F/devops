terraform {
required_providers {
aws = {
source  = "hashicorp/aws"
version = "~> 5.0"
}
}
}

provider "aws" {
region = var.aws_region
}

### Fetch the latest Ubuntu 22.04 LTS AMI

data "aws_ami" "ubuntu" {
most_recent = true
owners      = ["099720109477"] # Canonical 

filter {
name   = "name"
values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

filter {
name   = "virtualization-type"
values = ["hvm"]
}
}

### Create a Security Group to allow web traffic

resource "aws_security_group" "web_sg" {
name        = "allow-http"
description = "Allow inbound HTTP traffic"

ingress {
description = "HTTP from anywhere"
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}

### Provision the EC2 instance and pass the cloud-init file

resource "aws_instance" "web" {
ami                    = data.aws_ami.ubuntu.id
instance_type          = var.instance_type
associate_public_ip_address = true
subnet_id = "subnet-04b77ed5aad691e25"
vpc_security_group_ids = [aws_security_group.web_sg.id]

# Dynamically injects Terraform variables into the cloud-init template
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    web_package     = var.server_package
    welcome_message = var.custom_greeting
  })

  tags = {
    Name = "CloudInit-Dynamic-Webserver"
  }
}