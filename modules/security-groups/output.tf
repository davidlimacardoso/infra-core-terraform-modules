output "id" {
  value       = { for k, v in aws_security_group.create_sg : k => v.id }
  description = "Security group ID's"
}

output "name" {
  value       = { for k, v in aws_security_group.create_sg : k => v.name }
  description = "Security group names"
}