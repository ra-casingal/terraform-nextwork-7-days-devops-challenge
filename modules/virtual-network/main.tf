# Create a CIDR block for the VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Create a Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_route_cidr_block
    gateway_id = aws_internet_gateway.main.id
  }
}

# Create a Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_public_subnet_cidr_block
  availability_zone = var.vpc_availability_zone
  map_public_ip_on_launch = true
}

# Associate the Public Subnet with the Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}

# Filter AMI for Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = [var.ec2_ami_id_filter]
  }
}

# Create a EC2 instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id // Using Amazon Linux 2 AMI since Tomcat package is not available on Amazon Linux AMI and Amazon Linux 2023
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public.id

  tags = {
    role = var.ec2_codedeploy_tag
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y ruby wget
    cd /home/ec2-user
    wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
    chmod +x ./install
    sudo ./install auto
    systemctl enable codedeploy-agent
    systemctl start codedeploy-agent
  EOF

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

# Create a Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

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

# Attach the Security Group to the EC2 instance
resource "aws_network_interface_sg_attachment" "web_sg_attachment" {
  security_group_id    = aws_security_group.web_sg.id
  network_interface_id = aws_instance.web.primary_network_interface_id
}

# Create EC2 Server Role
resource "aws_iam_role" "ec2_role" {
  name = var.ec2_iam_service_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach SSM policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach S3 Read Only Access policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach Instance Profile to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.ec2_instance_profile_name
  role = aws_iam_role.ec2_role.name
}
