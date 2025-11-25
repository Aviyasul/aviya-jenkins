# ---------------------------
# Provider
# ---------------------------
provider "aws" {
  region = "us-east-2"
}

# ---------------------------
# Use existing VPC
# ---------------------------
data "aws_vpc" "aviya" {
  id = "vpc-0e2aff3cba7811bf7"
}

# ---------------------------
# Use existing Public Subnet
# ---------------------------
data "aws_subnet" "public_subnet" {
  id = "subnet-0b9ba22db170eef35"
}

# ---------------------------
# Find Amazon Linux 2 AMI
# ---------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ---------------------------
# Generate SSH Key Pair
# ---------------------------
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

# Upload public key to AWS
resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "builder_sg" {
  name        = "builder-sg"
  description = "Allow SSH and port 5001"
  vpc_id      = data.aws_vpc.aviya.id

  # Allow SSH from anywhere (you can restrict if needed)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP app on port 5001
  ingress {
    description = "Python app on port 5001"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "builder" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.medium"
  subnet_id                   = data.aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.builder_sg.id]
  key_name                    = aws_key_pair.builder_key.key_name

  tags = {
    Name = "builder"
  }
}

# ---------------------------
# Outputs
# ---------------------------
output "instance_public_ip" {
  value       = aws_instance.builder.public_ip
  description = "Public IP of the EC2 instance"
}

output "ssh_private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the generated private SSH key"
  sensitive   = true
}

output "ssh_key_name" {
  value       = aws_key_pair.builder_key.key_name
  description = "AWS SSH key pair name"
}

output "security_group_id" {
  value       = aws_security_group.builder_sg.id
  description = "Security Group ID"
}