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

variable "address_space" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "dashboard_subnet_prefix" {
  description = "CIDR block for the dashboard public subnet."
  default     = "10.0.10.0/24"
}

variable "counting_subnet_prefix" {
  description = "CIDR block for the counting private subnet."
  default     = "10.0.20.0/24"
}
