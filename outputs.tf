# 1. Publiczne IP Bastionu (do zarządzania przez SSH)
output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Publiczny adres IP Bastion Host do celów administracyjnych"
}

# 2. Publiczny adres URL dla użytkowników (nasz Load Balancer)
output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "Publiczny adres DNS Load Balancera. Wklej go do przeglądarki, aby zobaczyć aplikację!"
}