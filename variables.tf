# define aws region
variable "region" {
  default = "us-east-1"
}

variable "repo_name" {
  default = "tf-eks"
}

variable "front_repo_name" {
  default = "front-tf-eks"
}

variable "default_branch" {
  default = "master"
}

variable "build_image" {
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

# define build spec for build stage
variable "front_build_spec" {
  default = "front_buildspec/build.yml"
}

variable "front_deploy_spec" {
  default = "front_buildspec/deploy.yml"
}

# define build spec for build stage
variable "build_spec" {
  default = "buildspec/build.yml"
}

variable "deploy_spec" {
  default = "buildspec/deploy.yml"
}

variable "git_provider_type" {
  description = "Codestar connections support; GitHub, Bitbucket"
  default     = "GitHub"
}

variable "git_owner" {
  type        = string
  description = "owner"
  default     = "khaledbnmohamed"
}

variable "git_repo" {
  type        = string
  description = "Github repository name"
  default     = "test-demo"
}

variable "front_git_repo" {
  type        = string
  description = "Github repository name"
  default     = "frontend-test"
}
variable "git_branch" {
  type        = string
  description = "Github branch name"
  default     = "main"
}
variable "user_arn" {
  type = string
  description = "user arn"
  default = "arn:aws:iam::237094573095:root"
  
}

variable "user_account" {
  type = string
  description = "user arn"
  default = "237094573095"
  
}

variable "dockerhub_password" {
  type = string
  description = "dockerhub password"
  default = ")4@LDMy7dSGq6-@"
}
