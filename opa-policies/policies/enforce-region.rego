package terraform.policies.enforce_region

allowed_regions := {"eu-west-2"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  resource.change.actions[_] == "create"
  region := input.configuration.provider_config.aws.expressions.region.constant_value
  not allowed_regions[region]
  msg := sprintf(
    "AWS provider region '%s' is not allowed. Only %v are permitted.",
    [region, allowed_regions]
  )
}
