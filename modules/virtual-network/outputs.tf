# Output VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output Public Subnet ID
output "public_subnet_id" {
  value = aws_subnet.public.id
}

# Output EC2 Public DNS
output "ec2_instance_public_dns" {
  value = aws_instance.web.public_dns
}