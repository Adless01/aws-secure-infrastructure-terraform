# AWS Secure 3-Tier Infrastructure with Terraform & CI/CD Pipeline

A production-ready, highly secure, and fully automated infrastructure deployed on AWS using Infrastructure as Code (Terraform) and GitHub Actions. The architecture follows modern Cloud Security and SecOps standards to ensure strict network isolation, high availability, and automated deployments.

---

## 🛠️ Architecture & CI/CD Flow
[ Local Code (VS Code) ] ──(git push)──> [ GitHub Repository ]
│
▼
[ GitHub Actions Runner ]
│
(Automated Checks: FMT -> INIT -> PLAN)
│
▼
[ AWS S3 Backend (State Lock) ] <─────────> [ AWS Cloud ]
---

## 🏗️ Key Features

*   **Automated CI/CD Pipeline (GitHub Actions):** Fully automated workflow that triggers on every `git push`. It performs code formatting checks (`terraform fmt`), backend initialization (`terraform init`), and generates deployment plans (`terraform plan`) automatically.
*   **Secure Remote State (AWS S3 Backend):** Configured secure remote state storage in a private AWS S3 bucket with state locking (`backend.tf`) to prevent state corruption and ensure safe, team-oriented collaboration.
*   **Custom VPC & Multi-AZ Subnets:** Designed with separated Public and Private subnets across multiple Availability Zones (Multi-AZ) for fault tolerance and high availability.
*   **SecOps Network Hardening (Bastion Host):** Application servers are placed entirely within private subnets. Inbound SSH traffic is strictly restricted and only accessible via a dedicated Bastion Host.
*   **Traffic Management:** An Application Load Balancer (ALB) handles public traffic and safely routes it to the application layer.
*   **Multi-Environment Isolation (Terraform Workspaces):** Implemented dynamic state management allowing simultaneous, isolated deployment of development (DEV) and production (PROD) environments from a single codebase using `.tfvars` profiles.
*   **Automation:** Bash scripting (User Data) for automated server provisioning and bootstrapping.

---

## 💻 Tech Stack

*   **Cloud Provider:** AWS (VPC, EC2, ALB, S3, Security Groups, IAM)
*   **Infrastructure as Code:** Terraform (Workspaces, Variables, Remote State/S3 Backend, Dynamic Blocks)
*   **CI/CD & Automation:** GitHub Actions (YAML workflows)
*   **Scripting & CLI:** Bash, PowerShell
*   **Version Control:** Git & GitHub

---

## 🚦 How to Run Locally
   ```bash
   git clone [https://github.com/Adless01/aws-secure-3tier-network.git](https://github.com/Adless01/aws-secure-3tier-network.git)
