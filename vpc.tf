# === ROZWIĄZANIE BŁĘDU MEDIUM (Result #10) - VPC Flow Logs ===

# 1. Tworzymy bezpieczny kubełek S3 na logi sieciowe
resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket        = "${var.project_name}-${var.environment}-flow-logs-bucket-cl"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-logs-bucket"
    Environment = var.environment
  }
}

# 2. Konfigurujemy Flow Logs dla naszego głównego VPC
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