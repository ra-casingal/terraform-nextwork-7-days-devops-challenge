# Output VPC ID
output "vpc_id" {
  value = module.virtual_network.vpc_id
}

# Output Public Subnet ID
output "public_subnet_id" {
  value = module.virtual_network.public_subnet_id
}

# Output EC2 Public DNS
output "ec2_instance_public_dns" {
  value = module.virtual_network.ec2_instance_public_dns
}