variable "project_name" {
    type        = string
    description = "Project name"
    default     = "nextwork-devops-challenge-cicd"
}

variable "codeartifact_upstream_repository_name" {
    type        = string
    description = "CodeArtifact upstream repository name"
}

variable "s3_bucket_artifacts_name" {
    type        = string
    description = "S3 bucket name for storing build artifacts"
}

variable "iam_codebuild_role_name" {
    type        = string
    description = "IAM role name for CodeBuild"
}

variable "iam_codebuild_service_role_name" {
    type        = string
    description = "IAM service role name for CodeBuild"
}

variable "codedeploy_service_role_name" {
    type        = string
    description = "IAM service role name for CodeDeploy"
}

variable "codepipeline_service_role_name" {
    type        = string
    description = "IAM service role name for CodePipeline"
}

variable "codestar_connection_arn" {
    type        = string
    description = "CodeStar connection ARN for connecting to GitHub repository"
}

variable "github_full_name" {
    type        = string
    description = "GitHub repository full name (e.g., owner/repo)"
}

variable "github_branch" {
    type        = string
    description = "GitHub branch to use"
    default     = "main"
}