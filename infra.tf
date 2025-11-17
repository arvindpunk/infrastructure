terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.21"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "instance" {
  name        = "c6g-instance-sg"
  description = "Security group for c6g.xlarge instance"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP in production
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Minecraft access
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "c6g-instance-sg"
  }
}

data "aws_ami" "nixos_arm64" {
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/25.05*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# EC2 Instance
resource "aws_instance" "c6g_instance" {
  ami           = data.aws_ami.nixos_arm64.id
  instance_type = "c6g.large"
  subnet_id     = aws_subnet.public.id
  
  vpc_security_group_ids = [aws_security_group.instance.id]
  
  # Key pair for SSH access (create this in AWS first)
  key_name = "personal-ed25519"  # Change to your key pair name

  # Enable detailed monitoring
  monitoring = true

  # Root volume configuration
  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name = "c6g-xlarge-instance"
  }
}

# Additional EBS Volume (persistent data volume)
resource "aws_ebs_volume" "data" {
  availability_zone = "ap-south-1a"
  size              = 10  # Size in GB, adjust as needed
  type              = "gp3"
  encrypted         = false

  tags = {
    Name = "c6g-data-volume"
  }

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false  # Set to true in production for extra safety
  }
}

# Attach the persistent volume to the instance
resource "aws_volume_attachment" "data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.c6g_instance.id

  # Keep volume when instance is destroyed
  skip_destroy = true
}

# Elastic IP (optional - for static public IP)
resource "aws_eip" "instance" {
  instance = aws_instance.c6g_instance.id
  domain   = "vpc"

  tags = {
    Name = "c6g-instance-eip"
  }
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.c6g_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_eip.instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.c6g_instance.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.c6g_instance.public_dns
}

output "data_volume_id" {
  description = "ID of the persistent data volume"
  value       = aws_ebs_volume.data.id
}

output "data_volume_device" {
  description = "Device name for the data volume"
  value       = "/dev/sdf (may appear as /dev/nvme1n1 on the instance)"
}