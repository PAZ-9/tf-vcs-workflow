variable "region" {
  description = "The AWS region where resources are created."
  default     = "eu-west-2"
}

variable "prefix" {
  description = "Prefix included in the name of most resources."
  default     = "counting-dashboard"
}

variable "environment" {
  description = "Target environment."
  default     = "Production"
}

variable "instance_type" {
  description = "AWS EC2 instance type."
  default     = "t3.micro"
}

variable "department" {
  description = "Department tag value."
  default     = "devops"
}

variable "tfc_organization" {
  description = "HCP Terraform organization name."
  type        = string
  default     = "CloudIX"
}

variable "networking_workspace" {
  description = "Name of the HCP Terraform networking workspace to read remote state from."
  type        = string
  default     = "tf-vcs-networking"
}
