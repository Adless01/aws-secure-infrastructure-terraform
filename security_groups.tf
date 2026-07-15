# ==========================================
# 1. SECURITY GROUP DLA LOAD BALANCERA (ALB)
# ==========================================
resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.project_name}-${var.environment}-alb-sg-"
  description = "Security group for Application Load Balancer allowing public HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow public HTTP traffic to ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ALB to send outbound traffic anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# ==========================================
# 2. SECURITY GROUP DLA BASTION HOSTA
# ==========================================
resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-sg-"
  description = "Security group for Bastion Host allowing SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow public SSH access to Bastion (In prod, restrict to corporate VPN IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow Bastion to send outbound traffic anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-sg"
    Environment = var.environment
  }
}

# ==========================================
# 3. SECURITY GROUP DLA INSTANCJI APLIKACYJNYCH (APP)
# ==========================================
resource "aws_security_group" "app_sg" {
  name_prefix = "${var.project_name}-${var.environment}-app-sg-" # Zmienione na name_prefix dla spójności i braku konfliktów
  description = "Security group for application instances restricting access to ALB and Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow traffic from ALB to application instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow application instances to send outbound traffic anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-sg"
    Environment = var.environment
  }
}
