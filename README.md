# Terraform `for_each` unknown computed value

#### TL;DR -

1. Using a `for_each` loop over a map of values where the keys are static and the values can be either static or computed, works as expected per https://github.com/hashicorp/terraform/issues/4149 and https://github.com/hashicorp/terraform/issues/30937
2. If you take that logic and move it into a module, it still functions as expected (without issue related to `The "for_each" value depends on resource attributes that cannot be determined until apply...`)
3. If you take the module from 2 above and wrap it in a module that uses a `for_each` loop, you get the error `The "for_each" value depends on resource attributes that cannot be determined until apply...` even though the map keys are all static and known
