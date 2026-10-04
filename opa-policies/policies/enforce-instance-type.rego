package terraform.policies.enforce_instance_type

allowed_types := {"t3.micro"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  resource.change.actions[_] == "create"
  instance_type := resource.change.after.instance_type
  not allowed_types[instance_type]
  msg := sprintf(
    "EC2 instance '%s' uses instance type '%s'. Only %v are allowed.",
    [resource.address, instance_type, allowed_types]
  )
}
