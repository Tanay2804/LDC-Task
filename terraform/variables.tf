variable "admin_cidr" {
  description = "Trusted CIDR block for administrative access (SSH, Jenkins, SonarQube) for a single IP"
  type        = string
  default     = "0.0.0.0/0" # CHANGE THIS to your IP/CIDR in production
}
