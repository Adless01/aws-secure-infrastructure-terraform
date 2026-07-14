# AWS Secure 3-Tier Infrastructure via Terraform

## 📌 Project Overview
This repository contains a production-ready, highly secure, and automated infrastructure deployed on AWS using Infrastructure as Code (Terraform). The architecture follows modern Cloud Security and SecOps standards to ensure strict network isolation and high availability.

## 🏗️ Architecture Features
* **Custom VPC & Multi-AZ Subnets:** Designed with separated Public and Private subnets across multiple Availability Zones for fault tolerance.
* **SecOps Network Hardening (Bastion Host):** Application servers are placed entirely within private subnets. Inbound SSH traffic is strictly restricted and only accessible via a dedicated Bastion Host.
* **Traffic Management:** An Application Load Balancer (ALB) handles public traffic and safely routes it to the application layer.
* **Multi-Environment Isolation (Terraform Workspaces):** Implemented dynamic backend management allowing simultaneous, isolated deployment of `development` and `production` environments from a single codebase using `.tfvars` profiles.

## 🛠️ Tech Stack
* **Cloud Provider:** AWS (VPC, EC2, ALB, Security Groups)
* **Infrastructure as Code:** Terraform (Workspaces, Dynamic blocks, Variables)
* **Automation:** Bash scripting (User Data for server bootstrapping)
