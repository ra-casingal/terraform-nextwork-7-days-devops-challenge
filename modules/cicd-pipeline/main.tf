# Create CodeArtifact Domain
resource "aws_codeartifact_domain" "main" {
  domain = var.codeartifact_domain_name
}
# Create a upstream repository (Maven Central)
resource "aws_codeartifact_repository" "upstream" {
  repository = var.codeartifact_upstream_repository_name
  domain     = aws_codeartifact_domain.main.domain
}

# Create CodeArtifact Repository
resource "aws_codeartifact_repository" "main" {
  repository = var.codeartifact_repository_name
  domain     = aws_codeartifact_domain.main.domain
  external_connections {
    external_connection_name = "public:maven-central"
  }
}

# Create a S3 Bucket for storing CodeBuild artifacts
resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = var.s3_bucket_artifacts_name
  force_destroy = true
}

# Create IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = var.iam_codebuild_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# Create CodeBuild Project
resource "aws_codebuild_project" "nextwork_devops_challenge_cicd" {
  name          = var.codebuild_project_name
  description   = "CodeBuild project for Nextwork DevOps Challenge CI/CD pipeline"
  build_timeout = 60

  source {
    type            = "GITHUB"
    location        = "https://github.com/ra-casingal/nextwork-web-project"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
    report_build_status = true
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:corretto8"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  service_role = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type            = "S3"
    location        = aws_s3_bucket.codebuild_artifacts.bucket
    name            = "nextwork-devops-challenge-cicd-artifact"
    packaging       = "ZIP"
    path            = ""
    override_artifact_name = true
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = "/aws/codebuild/nextwork-devops-challenge-cicd"
      stream_name = "build-log"
    }
    s3_logs {
      status = "DISABLED"
    }
  }
}

# Create Service Role for CodeBuild
resource "aws_iam_role" "codebuild_service_role" {
  name = var.iam_codebuild_service_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "codebuild.amazonaws.com"
            }
        }
        ]
    })
}

# Attach CodeConnections policy to CodeBuild Role
resource "aws_iam_policy" "codebuild_use_connection_policy" {
  name        = "CodeBuildUseConnectionPolicy"
  description = "Policy to allow CodeBuild to use CodeConnection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection",
          "codeconnections:GetConnectionToken"
        ]
        Resource = "arn:aws:codeconnections:us-east-1:109625812894:connection/b82db962-e33e-46ba-8fe8-c67358bfdd96" // Change to ENV variable later
      }
    ]
  })
}

# Attach the CodeBuildUseConnectionPolicy to the CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_use_connection_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_use_connection_policy.arn
}

# Create CodeArtifact Consumer Policy
resource "aws_iam_policy" "codeartifact_nextwork_devops_challenge_consumer_policy" {
  name        = "codeartifact-nextwork-devops-challenge-consumer-policy"
  description = "Provides permissions to read from CodeArtifact. Created as a part of 7 Days DevOps Challenge CICD Pipeline series."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "sts:GetServiceBearerToken"
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach CodeArtifact Consumer Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codeartifact_consumer_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codeartifact_nextwork_devops_challenge_consumer_policy.arn
}

# Attach AWSCodeBuildDeveloperAccess policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_service_role_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# Attach CodeArtifact Consumer Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_service_role_codeartifact_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.codeartifact_nextwork_devops_challenge_consumer_policy.arn
}

# Attach CodeConnections policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_service_role_use_connection_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.codebuild_use_connection_policy.arn
}

# Attach S3 policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_service_role_s3_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach CloudWatch logs policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_service_role_cloudwatch_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Create CodeDeploy Application
resource "aws_codedeploy_app" "nextwork_devops_challenge_cicd" {
  name              = var.codedeploy_application_name
  compute_platform  = "Server"
}

# Create an IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy_service_role" {
  name = var.codedeploy_service_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AWSCodeDeployRole policy to the IAM Role
resource "aws_iam_role_policy_attachment" "codedeploy_service_role_policy_attach" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Create a CodeDeploy deployment group
resource "aws_codedeploy_deployment_group" "nextwork_devops_challenge_cicd_deployment_group" {
  app_name               = aws_codedeploy_app.nextwork_devops_challenge_cicd.name
  deployment_group_name  = var.codedeploy_deployment_group_name
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
    # No load_balancer_info block included, so load balancing is disabled
  deployment_style {
    deployment_type = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "role"
      type  = "KEY_AND_VALUE"
      value = "webserver"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# Create an Service Role for CodePipeline
resource "aws_iam_role" "codepipeline_service_role" {
  name = var.codepipeline_service_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create IAM Policy for CodePipeline to access S3, CodeBuild, and CodeStar Connections
data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codebuild_artifacts.arn,
      "${aws_s3_bucket.codebuild_artifacts.arn}/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = ["arn:aws:codeconnections:us-east-1:109625812894:connection/b82db962-e33e-46ba-8fe8-c67358bfdd96"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = [
      "*"
    ]
  }
}

# Create IAM Policy for CodePipeline
resource "aws_iam_policy" "codepipeline_policy" {
  name        = "NextWorkCodePipelinePolicy"
  description = "Policy for CodePipeline to access S3, CodeBuild, and CodeStar Connections"

  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# Attach the CodePipeline Policy to the CodePipeline Service Role
resource "aws_iam_role_policy_attachment" "codepipeline_service_role_codepipeline_policy_attach" {
  role       = aws_iam_role.codepipeline_service_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

# Create CodePipeline Pipeline
resource "aws_codepipeline" "nextwork_devops_challenge_cicd" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_service_role.arn
  pipeline_type = "V2"
  execution_mode = "SUPERSEDED"
  artifact_store {
    location = aws_s3_bucket.codebuild_artifacts.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn = var.codestar_connection_arn
        FullRepositoryId = var.github_full_name
        BranchName = var.github_branch
        DetectChanges = "true"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.nextwork_devops_challenge_cicd.name
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ApplicationName = aws_codedeploy_app.nextwork_devops_challenge_cicd.name
        DeploymentGroupName = aws_codedeploy_deployment_group.nextwork_devops_challenge_cicd_deployment_group.deployment_group_name
      }
    }
  }
}
