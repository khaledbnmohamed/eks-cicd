resource "aws_ecr_repository" "tf-eks-ecr" {
  name = var.repo_name
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "${var.repo_name}-${random_string.suffix.result}"
  acl           = "private"
  force_destroy = "true"
}

# encryption key for build artifacts
resource "aws_kms_key" "artifact_encryption_key" {
  description             = "artifact-encryption-key"
  deletion_window_in_days = 10
}
