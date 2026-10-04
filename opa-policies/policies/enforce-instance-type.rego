package terraform.policies.enforce_instance_type

deny contains msg if {
  true
  msg := sprintf("input top-level keys: %v", [object.keys(input)])
}
