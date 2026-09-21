variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "server_package" {
  type        = string
  default     = "nginx"
  description = "The web server package to install (e.g., nginx or apache2)"
}

variable "custom_greeting" {
  type        = string
  default     = "Hello from Terraform, Cloud-Init, and Templatefile!"
  description = "The custom message displayed on the index homepage"
}
