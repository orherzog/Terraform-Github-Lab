# Defining Region
variable "aws_region" {
  default = "us-east-2"
}

# Defining CIDR Block for VPC
variable "vpc_cidr" {
  default = "20.0.0.0/16"
}

# Defining CIDR Block for Subnet
variable "subnet_cidr" {
  default = "20.0.1.0/24"
}

# Defining CIDR Block for 2d Subnet
variable "subnet1_cidr" {
  default = "20.0.2.0/24"
}

# Defining AMI
variable "ami" {
  default = {
    eu-west-1 = "ami-0ea3405d2d2522162"
    us-east-2 = "ami-07d7e3e669718ab45"
  }
}

# Defining Instace Type
variable "instancetype" {
  default = "t2.medium"
}

# Defining Master count 
variable "master_count" {
  default = 1
}