variable "vpc_cidr" {
  description = "Główny zakres IP dla naszego VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Adresy IP dla podsieci publicznych (Web/Load Balancer)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Adresy IP dla podsieci prywatnych (Aplikacje)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnet_cidrs" {
  description = "Adresy IP dla podsieci izolowanych (Bazy danych)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "availability_zones" {
  description = "Strefy dostępności AWS (High Availability)"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"] # Region Frankfurt - najbliżej Polski
}