data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet_ids" "subnetsPub" {
  vpc_id = aws_vpc.vpc.id  

  tags = {
    Tier = "Public"
  }
 depends_on = [aws_subnet.public01, aws_subnet.public02, aws_subnet.public03 ] 
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true


  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-gw"
  }
}

resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 3, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch  = true

  tags = {
    Name = "${var.project}-public01"
    Tier = "Public"
  }
}

resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 3, 1)
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch  = true

  tags = {
    Name = "${var.project}-public02"
    Tier = "Public"
  }
}

resource "aws_subnet" "public03" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 3, 2)
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch  = true

  tags = {
    Name = "${var.project}-public03"
    Tier = "Public"
  }
}

resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 3, 3)
  availability_zone = data.aws_availability_zones.available.names[0]
  

  tags = {
    Name = "${var.project}-private01"
    Tier = "Private"
  }
}

resource "aws_subnet" "private02" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 3, 4)
  availability_zone = data.aws_availability_zones.available.names[1]
  

  tags = {
    Name = "${var.project}-private02"
    Tier = "Private"
  }
}

resource "aws_subnet" "private03" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 3, 5)
  availability_zone = data.aws_availability_zones.available.names[2]
  

  tags = {
    Name = "${var.project}-private03"
    Tier = "Private"
  }
}

resource "aws_eip" "eip" {
  vpc      = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public03.id

  tags = {
    Name = "${var.project}-nat-gw"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "pubrtbl" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project}-pubrtbl"
  }
}

resource "aws_route_table" "privrtbl" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.project}-privrtbl"
  }
}

resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.pubrtbl.id
}

resource "aws_route_table_association" "public02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.pubrtbl.id
}

resource "aws_route_table_association" "public03" {
  subnet_id      = aws_subnet.public03.id
  route_table_id = aws_route_table.pubrtbl.id
}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.privrtbl.id
}

resource "aws_route_table_association" "private02" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.privrtbl.id
}

resource "aws_route_table_association" "private03" {
  subnet_id      = aws_subnet.private03.id
  route_table_id = aws_route_table.privrtbl.id
}
