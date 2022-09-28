# Simple wrapper module which accepts a map of maps for creating multiple within one module definition
# plus allows for setting a default configuration where each individual specific definition can override

module "nested" {
  source = "../../"

  for_each = { for k, v in var.fargate_profiles : k => v if var.create }

  create = try(each.value.create, true)

  name = try(each.value.name, each.key)

  # IAM role
  create_iam_role               = try(each.value.create_iam_role, var.fargate_profile_defaults.create_iam_role, true)
  iam_role_name                 = try(each.value.iam_role_name, var.fargate_profile_defaults.iam_role_name, null)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, var.fargate_profile_defaults.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, var.fargate_profile_defaults.iam_role_path, null)
  iam_role_description          = try(each.value.iam_role_description, var.fargate_profile_defaults.iam_role_description, "Fargate profile IAM role")
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, var.fargate_profile_defaults.iam_role_permissions_boundary, null)
  iam_role_tags                 = try(each.value.iam_role_tags, var.fargate_profile_defaults.iam_role_tags, {})
  # To better understand why this `lookup()` logic is required, see:
  # https://github.com/hashicorp/terraform/issues/31646#issuecomment-1217279031
  iam_role_additional_policies = lookup(each.value, "iam_role_additional_policies", lookup(var.fargate_profile_defaults, "iam_role_additional_policies", {}))

  tags = merge(var.tags, try(each.value.tags, var.fargate_profile_defaults.tags, {}))
}
