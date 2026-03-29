output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ssh_user" {
  description = "Default SSH user for Amazon Linux 2"
  value       = local.ssh_user
}

output "key_name" {
  description = "AWS key pair name"
  value       = aws_key_pair.this.key_name
}

output "private_key_path" {
  description = "Local path to the generated private key"
  value       = local.private_key_path
}
