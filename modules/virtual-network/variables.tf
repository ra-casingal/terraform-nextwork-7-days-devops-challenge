variable "vpc_public_subnet_cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_route_cidr_block" {
  description = "The CIDR block for the route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ec2_ami_id_filter" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "amzn2-ami-hvm-*-x86_64-gp2" # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_iam_service_role_name" {
  description = "The name of the IAM service role for the EC2 instance"
  type        = string
  default     = "ec2-service-role"
}

variable "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile"
  type        = string
  default     = "ec2-instance-profile"
}

variable "ec2_codedeploy_tag" {
  description = "Tag to identify the EC2 instance for CodeDeploy"
  type        = string
  default     = "webserver"
}