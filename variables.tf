locals {
  install_script = file("${path.module}/install.sh")
}


variable "environment" {
    type = string
    default = "dev"
  
}

variable "region" {
    type = string
    default = "us-east-1"
  
}

variable "sgName" {
    type = string
    default = "Docker-swarm-SG"
  
}