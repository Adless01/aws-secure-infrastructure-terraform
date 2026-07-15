# ==========================================
# 1. GŁÓWNA SIEĆ VPC (Zwróć uwagę na nazwę "main")
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

# ==========================================
# 2. VPC FLOW LOGS (Do zabezpieczenia sieci)
# ==========================================
resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket        = "${var.project_name}-${var.environment}-flow-logs-bucket-cl"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-logs-bucket"
    Environment = var.environment
  }
}

resource "aws_flow_log" "main_flow_log" {
  log_destination      = aws_s3_bucket.flow_logs_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id # To odwołanie teraz zadziała!

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-log"
    Environment = var.environment
  }
}