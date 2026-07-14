
variable "instance_type" {
  type        = string
  default     = "t3.micro" # Darmowy pakiet (Free Tier)
  description = "Typ instancji EC2 dla maszyn w architekturze"
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1" # Region Frankfurt
  description = "Glowny region AWS dla infrastruktury"
}

variable "environment" {
  description = "Nazwa srodowiska (np. dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nazwa projektu uzywana do tagowania"
  type        = string
  default     = "CombatSec"
}

variable "vpc_cidr" {
  description = "Glowna pula adresowa VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "asg_max_size" {
  description = "Maksymalna liczba maszyn w Auto Scaling Group"
  type        = number
  default     = 2
}
