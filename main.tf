resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true


  tags = local.vpc_final_tags
}

#creating igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id #vpc association

  tags = local.igw_final_tags
}

#creating public subnets
# resource "aws_subnet" "public" {
#   count = length(var.subnet_cidr)
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet_cidr[count.index]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "Main"
#   }
#}