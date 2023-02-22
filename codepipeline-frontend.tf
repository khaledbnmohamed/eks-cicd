# create a 3 stage pipeline
resource "aws_codepipeline" "front-eks-pipeline" {
  name     = var.front_repo_name
  role_arn = aws_iam_role.tf-eks-pipeline.arn

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact_encryption_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn    = one(aws_codestarconnections_connection.frontend.*.arn)
        FullRepositoryId = "${var.git_owner}/${var.front_git_repo}"
        BranchName       = var.git_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.front-eks-build.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.front-eks-deploy.name}"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "frontend" {
  name          = "frontend-codestar-cs"
  provider_type = "GitHub"
}


resource "aws_ssm_parameter" "dockerhub_password" {
  name        = "dockerhub_password"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.dockerhub_password

}
