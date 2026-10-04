package terraform.policies.deny_unrestricted_ssh

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"
  resource.change.actions[_] == "create"
  ingress := resource.change.after.ingress[_]
  ingress.from_port <= 22
  ingress.to_port >= 22
  ingress.cidr_blocks[_] == "0.0.0.0/0"
  msg := sprintf(
    "Security group '%s' allows unrestricted SSH (port 22) from 0.0.0.0/0. Restrict to known CIDRs.",
    [resource.address]
  )
}
