
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

variable "VPC_cidr" {
  type = string
  default = "192.168.0.0/16" 
}

variable "public_subnet_cidr" {
  type = string
  default = "192.168.1.0/24"
}  

variable "AZ" {
  type = string
  default = "us-east-2a"
}

variable "project-name" {
  type    = string
  default = "Docker-swarm"
}
