# 1. Dynamiczne pobieranie najnowszego AMI Ubuntu 24.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Oficjalny właściciel Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Rejestracja Twojego klucza SSH w AWS
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDv2giSwE9E617sDF+hOYRoNPiUbs1BtwcwyBkA5krGPA4C8/S6Se1UhK1cPu38RdgsbumdLmrxUi/qVUjlzCuAHka0ZF9zTgI1iJisE5jQCI18b8FTNTE0DAN5sfthxaE1PLNDefEtK4gxJTQAlawVvugxhtxtHZO/VeId1OJu+dI2ksq6YIpNUsSG6d0SPDUnUTz4YSq0y8uc4Ss3BAyqNi7gH0dUYBhH8ptHZAYaXDRJxbDQeBZk5PuVsl0nNAAjWn8DDsmu67qhuGk483s+6khfUaZVCjttkP10Z0x8t+YAWvZNaaMR4CRk2vfupLyAuaMAYgV2LGX8D+SAPKiJ adaml@AdamLesie" # Tutaj wklej CAŁY swój klucz publiczny (zaczynający się od ssh-rsa)
}

# 3. Bastion Host (Punkt wejścia SSH - w pierwszej podsieci publicznej)
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name        = "SecOps-Bastion-Host"
    Environment = "Production"
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "SecOps-App-LT-"
  image_id      = "ami-0ec7f9846da6b0f61" # Upewnij się, że masz tu swoje sprawne AMI z Ubuntu
  instance_type = var.instance_type

  # TA SEKRETA SEKCJA WYMUSI PUBLICZNE IP DLA MASZYN:
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Przekierowanie wszystkich logów do pliku, żeby sprawdzić co poszło nie tak
              exec > /var/log/user_data.log 2>&1
              
              echo "=== START USER DATA ==="
              sleep 10
              
              # Wymuszenie nieinteraktywnego trybu i aktualizacja
              export DEBIAN_FRONTEND=noninteractive
              sudo apt-get update -y
              
              # Instalacja Nginxa z ignorowaniem ostrzeżeń o restartach usług
              sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" nginx
              
              # Wymuszenie startu i włączenia usługi
              sudo systemctl start nginx
              sudo systemctl enable nginx
              
              # Stworzenie strony głównej
              sudo mkdir -p /var/www/html
              sudo echo "<h1>SecOps Sandbox - Serwer Produkcyjny za Load Balancerem Dziala Bezpiecznie</h1>" | sudo tee /var/www/html/index.html
              
              echo "=== END USER DATA ==="
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 5. AUTO SCALING GROUP (ASG) - Zarządzanie flotą serwerów
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "SecOps-App-ASG-"
  desired_capacity    = 2 # Chcemy, aby zawsze działały dokładnie 2 maszyny
  max_size            = 4 # W razie potężnego ruchu system może dołożyć do 4 maszyn
  min_size            = 1 # W razie przestoju minimum 1 maszyna musi żyć
  vpc_zone_identifier = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  target_group_arns = [aws_lb_target_group.app_tg.arn] # Wpięcie maszyn pod nasz Load Balancer

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Informujemy AWS, żeby przy decyzjach o skalowaniu brał pod uwagę stan zdrowia z Load Balancera
  health_check_type         = "ELB"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
}