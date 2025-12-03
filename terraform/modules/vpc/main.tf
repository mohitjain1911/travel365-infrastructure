data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, index(var.public_subnet_cidrs, each.value) % length(data.aws_availability_zones.available.names))
  tags = { Name = "${var.name}-public-${each.value}" }
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = false
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.value) % length(data.aws_availability_zones.available.names))
  tags = { Name = "${var.name}-private-${each.value}" }
}

resource "aws_eip" "nat" {
  count = var.enable_nat ? length(var.public_subnet_cidrs) : 0
}

resource "aws_nat_gateway" "nat" {
  count = var.enable_nat ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(values(aws_subnet.public)[*].id, count.index)
  tags = { Name = "${var.name}-nat-${count.index}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-private-rt" }
}

resource "aws_route" "private_nat" {
  count = var.enable_nat ? 1 : 0
  route_table_id = aws_route_table.private.id
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, 0)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
}

 
