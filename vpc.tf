# 1. Główna sieć VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "SecOps-Main-VPC"
  }
}

# 2. Brama do internetu (Internet Gateway) - TYLKO JEDNA!
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "SecOps-IGW" }
}

# Dynamiczne pobieranie stref dostępności (np. eu-central-1a, eu-central-1b)
data "aws_availability_zones" "available" {
  state = "available"
}

# 3. DWIE PODSIECI PUBLICZNE
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24" # Stworzy 10.0.1.0/24 i 10.0.2.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Wymuszenie publicznego IP w tej sieci!

  tags = {
    Name = "SecOps-Public-Subnet-${count.index + 1}"
  }
}

# 4. DWIE PODSIECI PRYWATNE
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24" # Stworzy 10.0.10.0/24 i 10.0.11.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "SecOps-Private-Subnet-${count.index + 1}"
    Environment = "Production"
  }
}

# 5. Jedna, wspólna Tabela Tras dla ruchu publicznego
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "SecOps-Public-RouteTable"
  }
}

# 6. Automatyczne powiązanie OBU podsieci publicznych z tabelą routingu
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# ==========================================
# KONFIGURACJA NAT GATEWAY DLA SIECI PRYWATNEJ
# ==========================================

# 1. Elastyczne IP (Elastic IP) dla bramy NAT
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "SecOps-NAT-EIP" }
}

# 2. Brama NAT Gateway - MUSI stać w podsieci publicznej!
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id # Wrzucamy do pierwszej podsieci publicznej

  tags = { Name = "SecOps-NAT-Gateway" }
}

# 3. Tabela tras dla podsieci prywatnych (Ruch na świat idzie przez NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "SecOps-Private-RouteTable" }
}

# 4. Powiązanie OBU podsieci prywatnych z nową tabelą tras NAT
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}