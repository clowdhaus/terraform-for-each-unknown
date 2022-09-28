provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/clowdhaus/terraform-for-each-unknown"
  }
}

################################################################################
# Module
################################################################################

# Module instantiation maps directly to module definition
module "direct" {
  source = "../.."

  name = local.name

  # This works when used directly and circumvents the known issues in
  # - https://github.com/hashicorp/terraform/issues/4149
  # - https://github.com/hashicorp/terraform/issues/30937
  # due to the use of a static key and the computed value is used as the value
  iam_role_additional_policies = {
    "additional" = aws_iam_policy.additional.arn
  }

  tags = local.tags
}

# Module instantiation points at a sub-module which wraps the module definition
# within a `for_each` loop for creating multiples within one module instantiation
module "nested" {
  source = "../../modules/nested"

  fargate_profiles = {
    one = {
      # This does NOT work when its nested for reasons that I do not yet understand and
      # am trying to figure out. Normally, module nesting is something I would prefer to avoid
      # but in some scenarios it is quite useful (i.e. - in scenarios where you want to stamp out
      # a repeatable set of logic used in a higher order module https://github.com/terraform-aws-modules/terraform-aws-eks/blob/32000068258828b812b3b6f76efcb2b452b810f3/node_groups.tf#L196-L464)
      #
      # This is what I am after - trying to figure out
      # 1. Is this possible with what we know about #4149 and #30937 (i.e. - can we use a static key even when nesting maps within maps)
      # 2. If it is possible, what does that solution look like to avoid the unknown computed values when nesting maps within maps
      iam_role_additional_policies = {
        "additional" = aws_iam_policy.additional.arn
      }

      tags = local.tags
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_iam_policy" "additional" {
  name = "${local.name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
