# ==========================================
# 1. GŁÓWNA SIEĆ VPC
# ==========================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# Dynamiczne pobieranie stref dostępności w danym regionie
data "aws_availability_zones" "available" {
  state = "available"
}

# ==========================================
# 2. PODSIECI PUBLICZNE
# ==========================================
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24" # 10.0.1.0/24, 10.0.2.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# ==========================================
# 3. PODSIECI PRYWATNE
# ==========================================
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24" # 10.0.10.0/24, 10.0.11.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# ==========================================
# 4. INTERNET GATEWAY & ROUTING (Dla podsieci publicznych)
# ==========================================
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# 5. VPC FLOW LOGS & S3 (Zabezpieczenie i audyt sieci)
# ==========================================

# Kubełek S3 na logi
resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket        = lower("${var.project_name}-${var.environment}-flow-logs-bucket-cl")
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-logs-bucket"
    Environment = var.environment
  }
}

# WŁAŚCIWY FLOW LOG - Aktywacja i powiązanie z VPC oraz S3
resource "aws_flow_log" "main_flow_log" {
  log_destination      = aws_s3_bucket.flow_logs_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-log"
    Environment = var.environment
  }
}