output "ec2ipv4" {
  value       = aws_instance.server_1.public_ip
  description = "Ipv4"
}
