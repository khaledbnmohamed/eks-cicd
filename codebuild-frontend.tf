# build image and push to ECR
resource "aws_codebuild_project" "front-eks-build" {
  name         = "front-eks-build"
  description  = "Terraform front EKS Build"
  service_role = aws_iam_role.tf-eks-pipeline.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ECR_REPO"
      value = aws_ecr_repository.front-eks-ecr.repository_url
    }
    environment_variable {
      name  = "DOCKERHUB_PASSWORD"
      value = aws_ssm_parameter.dockerhub_password.value
    }
    
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.front_build_spec
  }

}

# deploy
resource "aws_codebuild_project" "front-eks-deploy" {
  name         = "front-eks-deploy"
  description  = "Terraform EKS Deploy"
  service_role = aws_iam_role.tf-eks-pipeline.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "EKS_NAMESPACE"
      value = "tf-eks-staging"
    }

    environment_variable {
      name  = "ECR_REPO"
      value = aws_ecr_repository.front-eks-ecr.repository_url
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.front_deploy_spec
  }

}
