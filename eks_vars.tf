# use local vars for EKS module
locals {
  cluster_name       = "terraform-eks-dev"
  cluster_version    = "1.21"
  config_output_path = "./"
  worker_groups = [
    {
      # This will launch an autoscaling group with only On-Demand instances
      name                 = "on_demand"
      instance_type        = "t2.small"
      ami_id               = "${data.aws_ami.eks_worker_ami.image_id}"
      subnets              = module.vpc.private_subnets
      asg_desired_capacity = "1"
    },
  ]
  map_roles = [
    {
      rolearn  = "${aws_iam_role.tf-eks-pipeline.arn}"
      username = "codepipeline"
      groups   = ["system:masters"]
    },
  ]
    map_users = [
      {
        userarn  = "${var.user_arn}"
        username = "codepipeline"
        groups   = ["system:masters"]
      },
    ]
  # worker_groups_launch_template = [
  #   {
  #     # This will launch an autoscaling group with only Spot Fleet instances
  #     name                                     = "spot_fleet"
  #     instance_type                            = "t2.small"
  #     ami_id                                   = "${data.aws_ami.eks_worker_ami.image_id}"
  #     subnets                                  = module.vpc.private_subnets
  #     additional_security_group_ids            = "${aws_security_group.worker_group_mgmt_one.id},${aws_security_group.worker_group_mgmt_two.id}"
  #     override_instance_type                   = "t3.small"
  #     asg_desired_capacity                     = "2"
  #     spot_instance_pools                      = 10
  #     on_demand_percentage_above_base_capacity = "0"
  #   },
  # ]

  tags = {
    Environment = "development"
  }
}

# get the latest Amazon Linux image optimised for EKS
data "aws_ami" "eks_worker_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["602401143452"]
}

