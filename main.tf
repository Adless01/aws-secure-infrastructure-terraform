# 1. Konfiguracja dostawcy AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # Region Frankfurt
}

# 2. Tworzenie głównego VPC z adresem IP ze zmiennej
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "SecOps-VPC"
    Environment = "Production"
    Project     = "Cloud-Security-Architecture"
  }
}

# 3. Tworzenie bramy internetowej (Internet Gateway) dla podsieci publicznych
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "SecOps-IGW"
  }
}
# 4. Podsieci Publiczne (Public Subnets)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # Automatyczne publiczne IP dla zasobów tutaj

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}

# 5. Podsieci Prywatne (Private Subnets)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}

# 6. Podsieci Izolowane / Bazodanowe (Database Subnets)
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Database-Subnet-${count.index + 1}"
  }
}
# 7. Publiczna Tabela Routingu (Public Route Table)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"             # Cały ruch wychodzący w świat...
    gateway_id = aws_internet_gateway.gw.id # ...kieruj przez naszą bramę internetową
  }

  tags = {
    Name = "SecOps-Public-RouteTable"
  }
}

# 8. Powiązanie Tabeli Routingu z Podsieciami Publicznymi (Association)
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 9. Prywatna Tabela Routingu (Dla warstwy aplikacji i baz - bez dostępu do IGW)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "SecOps-Private-RouteTable"
  }
}

# 10. Powiązanie z Podsieciami Prywatnymi
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# 11. Powiazanie z Podsieciami Bazodanowymi (Izolowanymi)
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private.id
}
# 12. Security Group dla serwera WWW (Ochroniarz)
resource "aws_security_group" "web_sg" {
  name        = "SecOps-Web-SG"
  description = "Zapora ogniowa dla serwerow WWW"
  vpc_id      = aws_vpc.main.id # Łaczymy ochroniarza z naszym VPC

  # Reguła 1: Wpuszczamy ruch HTTP (port 80) z całego internetu
  ingress {
    description = "Zezwol na ruch HTTP z internetu"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 oznacza CAŁY internet
  }

  # Reguła 2: Ruch wychodzący - pozwol serwerowi odpowiedziec w swiat
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" oznacza wszystkie protokoły
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecOps-Web-SG"
  }
}

# 13. Security Group dla bazy danych
resource "aws_security_group" "db_sg" {
  name        = "SecOps-DB-SG"
  description = "Zapora ogniowa dla bazy danych"
  vpc_id      = aws_vpc.main.id

  # Reguła 1: Wpuszczamy ruch TYLKO od ochroniarza warstwy webowej
  ingress {
    description     = "Zezwol na ruch z serwerow z odznaka Web-SG"
    from_port       = 5432 # Port PostgreSQL
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # TUTAJ laczymy ochroniarzy!
  }

  # Reguła 2: Ruch wychodzacy - bezpieczny powrot pakietow
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecOps-DB-SG"
  }
}