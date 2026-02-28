variable "project" {
    type =  string
}

variable "enviornment" {
    type = string
}

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_tags" {
    type = map
    default = {}
}

variable "igw_tags" {
    type = map
    default = {}
}

variable "subnet_cidr" {
    type = list
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_tags" {
    type = map
    default = {}
}   
