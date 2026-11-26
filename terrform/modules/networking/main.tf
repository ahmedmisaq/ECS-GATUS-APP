resource "aws_vpc" "Gatus_VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Gatus-Terraform-VPC"
  }
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "Gatus_Public_Subnet" {
  vpc_id                  = aws_vpc.Gatus_VPC.id
  count                   = length(var.public_subnet_cidr)
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Gatus-Terraform-Public-Subnet"
  }
}

resource "aws_subnet" "Gatus_Private_Subnet" {
  vpc_id                  = aws_vpc.Gatus_VPC.id
  count                   = length(var.private_subnet_ids)
  cidr_block              = var.private_subnet_ids[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Gatus-Terraform-Private-Subnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "Gatus_IGW" {
  vpc_id = aws_vpc.Gatus_VPC.id
  tags = {
    Name = "Gatus-Terraform-Internet-Gateway"
  }
}

resource "aws_route_table" "Gatus_Public_Route" {
  vpc_id = aws_vpc.Gatus_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Gatus_IGW.id
  }
  tags = {
    Name = "Gatus-Terraform-Public-Route-Table"
  }
}


resource "aws_route_table_association" "Gatus_Route_Table_Association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.Gatus_Public_Subnet[count.index].id
  route_table_id = aws_route_table.Gatus_Public_Route.id
}

resource "aws_nat_gateway" "Gatus_NGW" {
  allocation_id = aws_eip.Gatus_NAT_EIP.id
  subnet_id     = aws_subnet.Gatus_Public_Subnet[0].id
  depends_on    = [aws_internet_gateway.Gatus_IGW]
  tags = {
    Name = "Gatus-Terraform-Nat-Gateway"
  }
}


resource "aws_eip" "Gatus_NAT_EIP" {
  domain = "vpc"
  tags = {
    Name = "Gatus-Terraform-EIP"
  }
}


resource "aws_route_table" "Gatus_NAT_Gateway_Route_Table" {
  vpc_id = aws_vpc.Gatus_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Gatus_NGW.id
  }

  tags = {
    Name = "Gatus-Terraform-Nat-Gateway-Route-Table"
  }
}

resource "aws_route_table_association" "Gatus_Private_Route_Association" {
  count          = length(var.private_subnet_ids)
  subnet_id      = aws_subnet.Gatus_Private_Subnet[count.index].id
  route_table_id = aws_route_table.Gatus_NAT_Gateway_Route_Table.id
}