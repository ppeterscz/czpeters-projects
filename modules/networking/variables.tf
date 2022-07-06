variable "project" {
    description = "The Name of the Project"
}

variable "environment" {
    description = "The deployment environment"
    default = "production" 
}

variable "region" {
  description = "The AWS Region"
}

variable "availability_zones" {
 type = list(any)
 description = "The Availability zones available for use"
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
}

variable "public_subnets_cidr" {
  type = list(any)
  description = "The CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
    type = list(any)
    description = "The CIDR Block for Private usage"
}