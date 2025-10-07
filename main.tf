provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "nextwork-devops-challenge"
    }
  }
}

# Create a VPC that contains the web server
module "virtual_network" {
  source = "./modules/virtual-network"
}

# Create a CI/CD pipeline using CodePipeline, CodeBuild, and CodeDeploy
module "cicd_pipeline" {
  source = "./modules/cicd-pipeline"
  codeartifact_domain_name              = var.project_name
  codeartifact_repository_name          = var.project_name
  codeartifact_upstream_repository_name = var.codeartifact_upstream_repository_name
  s3_bucket_artifacts_name              = var.s3_bucket_artifacts_name
  iam_codebuild_role_name               = var.iam_codebuild_role_name
  iam_codebuild_service_role_name       = var.iam_codebuild_service_role_name
  codedeploy_service_role_name          = var.codedeploy_service_role_name
  codepipeline_service_role_name        = var.codepipeline_service_role_name
  codebuild_project_name                = var.project_name
  codedeploy_application_name           = var.project_name
  codedeploy_deployment_group_name      = var.project_name
  codepipeline_name                     = var.project_name
  codestar_connection_arn               = var.codestar_connection_arn
  github_full_name                      = var.github_full_name
  github_branch                         = var.github_branch
}