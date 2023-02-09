# define aws region
variable "region" {
  default = "us-east-1"
}

variable "repo_name" {
  default = "tf-eks"
}

variable "default_branch" {
  default = "master"
}

variable "build_image" {
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

# define build spec for build stage
variable "build_spec" {
  default = "buildspec/build.yml"
}

# docker image with necessary tools
variable "deploy_image" {
  default = "shawnxlw/ide"
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

variable "git_branch" {
  type        = string
  description = "Github branch name"
  default     = "main"
}
