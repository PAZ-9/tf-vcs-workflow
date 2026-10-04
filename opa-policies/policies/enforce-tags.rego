package terraform.policies.enforce_tags

required_tags := {"Name", "Department"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  resource.change.actions[_] == "create"
  tags := resource.change.after.tags
  required_tag := required_tags[_]
  not tags[required_tag]
  msg := sprintf(
    "EC2 instance '%s' is missing required tag '%s'.",
    [resource.address, required_tag]
  )
}
