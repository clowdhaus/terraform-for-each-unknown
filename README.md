# Terraform `for_each` unknown computed value

#### TL;DR -

1. Using a `for_each` loop over a map of values where the keys are static and the values can be either static or computed, works as expected per https://github.com/hashicorp/terraform/issues/4149 and https://github.com/hashicorp/terraform/issues/30937
2. If you take that logic and move it into a module, it still functions as expected (without issue related to `The "for_each" value depends on resource attributes that cannot be determined until apply...`)
3. If you take the module from 2 above and wrap it in a module that uses a `for_each` loop, you get the error `The "for_each" value depends on resource attributes that cannot be determined until apply...` even though the map keys are all static and known

### Solution

When iterating over a map of maps, if we use "eagerly evaluated" functions such as `try()` and `can()` will cause the well known `The "for_each" value depends on resource attributes that cannot be determined until apply...` error when a computed value is provided in a map value that is passed to a `try()` or `can()` function. To circumvent this eager/early evaluation, we can instead a nested set of `lookup()` which is not eager/early evaluated and avoids unknown value errors.

#### Fail ❌

```hcl
module "example" {
  source = "../../"

  for_each = { for k, v in var.fargate_profiles : k => v if var.create }

  ...

  iam_role_additional_policies = try(each.value.iam_role_additional_policies", var.fargate_profile_defaults.iam_role_additional_policies, {})
}
```

#### Pass ✔️

```hcl
module "example" {
  source = "../../"

  for_each = { for k, v in var.fargate_profiles : k => v if var.create }

  ...

  # To better understand why this `lookup()` logic is required, see:
  # https://github.com/hashicorp/terraform/issues/31646#issuecomment-1217279031
  iam_role_additional_policies = lookup(each.value, "iam_role_additional_policies", lookup(var.fargate_profile_defaults, "iam_role_additional_policies", {}))
}
```
