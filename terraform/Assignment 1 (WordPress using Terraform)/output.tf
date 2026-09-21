output "wordpress_website_url" {
  value = "http://${aws_instance.wp_server.public_ip}"
}