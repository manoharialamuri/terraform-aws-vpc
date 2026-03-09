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
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-public-${local.az_names[count.index]}"
        #name=roboshop-dev-public-us-east-1a
    },
    var.public_subnet_tags
  )
}

#creating private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-private-${local.az_names[count.index]}"
        #name=roboshop-dev-private-us-east-1a
    },
    var.private_subnet_tags
  )
}

#creating database subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-database-${local.az_names[count.index]}"
        #name=roboshop-dev-database-us-east-1a
    },
    var.database_subnet_tags
  )
}

#creating route table for public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags =merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-public"
        #name=roboshop-dev-public
    },
    var.public_route_table_tags
  )
}

#creating route table for private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags =merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-private"
        #name=roboshop-dev-private
    },
    var.private_route_table_tags
  )
}

#creating route table for database
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags =merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-database"
        #name=roboshop-dev-public
    },
    var.database_route_table_tags
  )
}