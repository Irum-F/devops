output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP address of the web server"
}
