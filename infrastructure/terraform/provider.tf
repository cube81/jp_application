provider "aws" {
  region = "us-east-1"
  profile = "default" # w ~/.aws/credentials
  shared_config_files      = ["/home/jp/.aws/credentials"]
}