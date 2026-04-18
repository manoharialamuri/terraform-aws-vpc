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

  tags = merge(
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

  tags = merge(
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

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-database"
        #name=roboshop-dev-public
    },
    var.database_route_table_tags
  )
}

#creating public route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

#creating EIP(nat)
resource "aws_eip" "nat" {
  domain                    = "vpc"
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-nat"
        #name=roboshop-dev-nat(ip)
    },
    var.eip_tags
  )
}

#creating NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id #we are creating only in one az us-east-1

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-nat"
        #name=roboshop-dev-nat
    },
    var.nat_gateway_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#creating private route
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

#creating database route
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr) # we use count becoz we have to ip's  to associate
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr) # we use count becoz we have to ip's  to associate
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr) # we use count becoz we have to ip's  to associate
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# Create the DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-${var.enviornment}"
  subnet_ids = [
    aws_subnet.database[0].id,
    aws_subnet.database[1].id
  ]
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}-nat"
        #name=roboshop-dev-nat
    }
  )
}

