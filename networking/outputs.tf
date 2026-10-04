output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.counting_dashboard_vpc.id
}

output "dashboard_subnet_id" {
  description = "ID of the dashboard public subnet."
  value       = aws_subnet.dashboard_subnet.id
}

output "counting_subnet_id" {
  description = "ID of the counting private subnet."
  value       = aws_subnet.counting_subnet.id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway."
  value       = aws_nat_gateway.nat.id
}
