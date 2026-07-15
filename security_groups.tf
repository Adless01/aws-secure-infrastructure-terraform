# ==========================================
# 1. GRUPY ZABEZPIECZEŃ (Puste szkielety bez wbudowanych reguł)
# ==========================================

resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.project_name}-${var.environment}-alb-sg-"
  description = "Security group for Application Load Balancer allowing public HTTP traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-sg-"
  description = "Security group for Bastion Host allowing SSH access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "${var.project_name}-${var.environment}-app-sg-"
  description = "Security group for application instances restricting access to ALB and Bastion"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-sg"
    Environment = var.environment
  }
}

# ==========================================
# 2. REGUŁY DLA LOAD BALANCERA (ALB)
# ==========================================

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow public HTTP traffic to ALB"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow ALB to send outbound traffic anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ==========================================
# 3. REGUŁY DLA BASTION HOSTA
# ==========================================

resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow public SSH access to Bastion"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ssh_cidr]
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow Bastion to send outbound traffic anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ==========================================
# 4. REGUŁY DLA INSTANCJI APLIKACYJNYCH (APP)
# ==========================================

resource "aws_security_group_rule" "app_http_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app_sg.id
  description              = "Allow HTTP traffic exclusively from ALB"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id # Powiązanie przez ID grupy ALB
}

resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app_sg.id
  description              = "Allow SSH access exclusively from Bastion Host"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id # Powiązanie przez ID grupy Bastiona
}

resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow instances to access the internet (updates, patching)"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}