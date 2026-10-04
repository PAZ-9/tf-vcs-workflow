##########################################################
# vpc
##########################################################

resource "aws_vpc" "counting_dashboard_vpc" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.prefix}-vpc-${var.region}"
    Environment = var.environment
  }
}

##########################################################
# dashboard subnet (public)
##########################################################

resource "aws_subnet" "dashboard_subnet" {
  vpc_id                  = aws_vpc.counting_dashboard_vpc.id
  cidr_block              = var.dashboard_subnet_prefix
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.prefix}-dashboard-public-subnet"
  }
}

##########################################################
# counting subnet (private)
##########################################################

resource "aws_subnet" "counting_subnet" {
  vpc_id            = aws_vpc.counting_dashboard_vpc.id
  cidr_block        = var.counting_subnet_prefix
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.prefix}-counting-private-subnet"
  }
}

##########################################################
# internet gateway
##########################################################

resource "aws_internet_gateway" "counting_dashboard" {
  vpc_id = aws_vpc.counting_dashboard_vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

##########################################################
# nat gateway
##########################################################

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.dashboard_subnet.id

  tags = {
    Name = "${var.prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.counting_dashboard]
}

##########################################################
# dashboard route table (public)
##########################################################

resource "aws_route_table" "dashboard_rt" {
  vpc_id = aws_vpc.counting_dashboard_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.counting_dashboard.id
  }

  tags = {
    Name = "${var.prefix}-dashboard-rt"
  }
}

resource "aws_route_table_association" "dashboard_rt_asso" {
  subnet_id      = aws_subnet.dashboard_subnet.id
  route_table_id = aws_route_table.dashboard_rt.id
}

##########################################################
# counting route table (private via NAT)
##########################################################

resource "aws_route_table" "counting_rt" {
  vpc_id = aws_vpc.counting_dashboard_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.prefix}-counting-rt"
  }
}

resource "aws_route_table_association" "counting_rt_asso" {
  subnet_id      = aws_subnet.counting_subnet.id
  route_table_id = aws_route_table.counting_rt.id
}
