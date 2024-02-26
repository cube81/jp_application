variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_key_name" {
  type        = string
  description = "jp-drmax"
}

variable "ssh_key_path" {
  type        = string
  description = "../jp-max.pem"
}
