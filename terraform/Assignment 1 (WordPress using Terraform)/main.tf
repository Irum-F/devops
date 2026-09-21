# 1. AWS Provider Configuration
provider "aws" {
  region = var.region
}

# 2. Network (Default VPC & Subnet to save space)
data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Security Group
resource "aws_security_group" "wp_sg" {
  name        = "wordpress-single-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# 4. Find the latest Ubuntu operating system image
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# 5. EC2 Server (Installs Apache, PHP, MySQL, and WordPress automatically)
resource "aws_instance" "wp_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
    associate_public_ip_address = true
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              
              # Install Apache, PHP, and MySQL Server
              DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
              
              # Configure MySQL Database
              mysql -e "CREATE DATABASE wordpress_db;"
              mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'SecurePassword123!';"
              mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'localhost';"
              mysql -e "FLUSH PRIVILEGES;"
              
              # Download and configure WordPress
              cd /var/www/html
              rm index.html
              wget https://wordpress.org
              tar -xzf latest.tar.gz
              cp -r wordpress/* .
              rm -rf wordpress latest.tar.gz
              
              # Set up wp-config.php automatically
              cp wp-config-sample.php wp-config.php
              sed -i "s/database_name_here/wordpress_db/" wp-config.php
              sed -i "s/username_here/wp_user/" wp-config.php
              sed -i "s/password_here/SecurePassword123!/" wp-config.php
              
              # Fix permissions so Apache can read/write files
              chown -R www-data:www-data /var/www/html
              systemctl restart apache2
              EOF

  tags = { Name = "wordpress-all-in-one" }
}