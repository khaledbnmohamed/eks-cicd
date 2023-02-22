resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "SG to be applied to all machines"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  tags = {
    "kubernetes.io/cluster/${module.eks.cluster_id}" = "shared"
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source                 = "terraform-aws-modules/eks/aws"
  version                = "17.2.0"
  cluster_name           = local.cluster_name
  cluster_version        = local.cluster_version
  kubeconfig_output_path = local.config_output_path
  subnets                = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
  enable_irsa = true
  worker_create_cluster_primary_security_group_rules = true
  # worker_groups_launch_template        = "${local.worker_groups_launch_template}"
  # worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles     = local.map_roles
  map_users = local.map_users
  worker_groups = local.worker_groups
#TODO: create networking 
  node_groups = {
    node_groups = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"
    }
  }
}

# use microservice k8s commun
module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

 
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}
