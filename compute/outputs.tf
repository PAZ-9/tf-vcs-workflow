output "dashboard_app_url" {
  description = "Public URL of the dashboard application."
  value       = "http://${aws_eip.counting_dashboard.public_dns}:9009"
}

output "dashboard_public_ip" {
  description = "Public IP of the dashboard instance."
  value       = aws_eip.counting_dashboard.public_ip
}

output "counting_private_ip" {
  description = "Private IP of the counting instance."
  value       = aws_instance.counting_instance.private_ip
}

output "dashboard_instance_private_key" {
  description = "Private key for SSH access."
  value       = tls_private_key.counting_dashboard_key.private_key_openssh
  sensitive   = true
}
