# 7 Days DevOps Challenge

This repository contains [ra-casingal](https://github.com/ra-casingal)'s Terraform configuration for [NextWork's 7 Days DevOps Challenge](https://learn.nextwork.org/projects/aws-devops-codepipeline-updated). The project is designed to demonstrate the implementation of a complete infrastructure-as-code (IaC) solution using Terraform. It provisions and manages AWS resources to set up a virtual network, deploy a web application, and create a CI/CD pipeline. This project uses [ra-casingal](https://github.com/ra-casingal)'s [Java Web Application Project](https://github.com/ra-casingal/nextwork-web-project) as the web app.

## Project Overview

The project is divided into multiple modules, each responsible for a specific part of the infrastructure:

### 1. **Virtual Network**
   - Creates a VPC with a public subnet.
   - Configures an Internet Gateway and Route Table for internet access.
   - Deploys an EC2 instance with a security group to allow HTTP and SSH traffic.
   - Sets up IAM roles and policies for the EC2 instance.

### 2. **CI/CD Pipeline**
   - Sets up AWS CodePipeline, CodeBuild, and CodeDeploy for continuous integration and deployment.
   - Creates an S3 bucket for storing build artifacts.
   - Configures CodeArtifact for managing dependencies.
   - Integrates with GitHub for source control.

## Repository Structure

```plaintext
.
├── main.tf                 # Root module configuration
├── variables.tf            # Root module variables
├── outputs.tf              # Root module outputs
├── prod.tfvars             # Production environment variable values
├── modules/                # Contains reusable Terraform modules
│   ├── cicd-pipeline/      # CI/CD pipeline module
│   └── virtual-network/    # Virtual network module
└── .terraform/             # Terraform state and provider files
```
## Prerequisites
- Terraform: Install Terraform CLI (v1.5.0 or later).
- AWS CLI: Configure AWS credentials for Terraform to interact with AWS.
- GitHub Repository: Ensure you have a Java Web App GitHub repository for the CI/CD pipeline.
- Create a AWS Developer Tool Code Connection for the Java Web App GitHub repository.

## How to Use
1. Clone the Repository:
```bash
git clone https://github.com/ra-casingal/terraform-nextwork-7-days-devops-challenge.git

cd terraform-nextwork-7-days-devops-challenge
```
2. Fill out the values in **prod.tfvars**:
3. Initialize Terraform:
```bash
terraform init
```
4. Plan the Infrastructure:
```bash
terraform plan -var-file="prod.tfvars"
```
5. Apply the Configuration:
```bash
terraform apply -var-file="prod.tfvars"
```
6. Destroy the Infrastructure (if needed):
```bash
terraform destroy -var-file="prod.tfvars"
```

## Key Features
- Infrastructure as Code: All resources are defined and managed using Terraform.
- Modular Design: Reusable modules for virtual network, CI/CD pipeline, and web application setup.
- AWS Integration: Leverages AWS services like VPC, EC2, S3, CodePipeline, CodeBuild, and CodeDeploy.
- GitHub Integration: Automates deployments from a GitHub repository.

## Future Enhancements
- Add support for multiple environments (e.g., staging, production).
- Implement monitoring and logging using AWS CloudWatch.
- Automate the creation of GitHub repositories and secrets.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

# Acknowledgments
This project is [ra-casingal](https://github.com/ra-casingal)'s Terraform implementation of [NextWork's 7 Days DevOps Challenge](https://learn.nextwork.org/projects/aws-devops-codepipeline-updated) and is inspired by best practices in DevOps and infrastructure automation.