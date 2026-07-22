# 🛡️ AWS Secure 3-Tier Infrastructure with Terraform, ECS Fargate & DevSecOps CI/CD

A production-ready, highly secure, and fully automated cloud infrastructure deployed on AWS using **Infrastructure as Code (Terraform)**, **Docker**, and **GitHub Actions**. The architecture follows modern Cloud Security and DevSecOps standards to ensure strict network isolation, high availability, container security, and automated deployments.

---

## 🛠️ Architecture & CI/CD Flow

```text
[ Local Code (VS Code) ] ──(git push)──> [ GitHub Repository ]
                                                 │
                                                 ▼
                                      [ GitHub Actions Runner ]
                                                 │
           ┌─────────────────────────────────────┴─────────────────────────────────────┐
           ▼                                                                           ▼
[ 1. Terraform Security Checks ]                                            [ 2. Docker & DevSecOps ]
  • terraform fmt -check                                                      • Build Docker Image
  • tfsec (IaC Static Analysis)                                               • Trivy Vulnerability Scan
           │                                                                           │
           └─────────────────────────────────────┬─────────────────────────────────────┘
                                                 ▼
                                     [ Push Image to AWS ECR ]
                                                 │
                                                 ▼
                                 [ AWS Cloud (ECS Fargate Deployment) ]
Key Features
Automated DevSecOps Pipeline (GitHub Actions): Fully automated CI/CD workflow running on every push. Performs code formatting (terraform fmt), static analysis (tfsec), Docker image builds, and vulnerability scanning with Trivy (CRITICAL/HIGH CVE checks) before pushing to AWS ECR.

Serverless Container Orchestration (AWS ECS Fargate): Containerized microservices running in isolated private subnets with no public IP exposure, eliminating server management and OS patching overhead.

Elastic Container Registry (AWS ECR): Encrypted private registry with image immutability and tag management ($GITHUB_SHA & latest).

Secure Remote State (AWS S3 & DynamoDB): Private S3 backend for remote state storage with active DynamoDB state locking (backend.tf) to prevent concurrent execution conflicts and state corruption.

Custom 3-Tier VPC Topology: Multi-AZ architecture with strict subnet isolation (Public, Private App, and Isolated Database tiers).

Traffic Isolation & SecOps: Public access is limited strictly to the Application Load Balancer (ALB), which safely routes traffic to private ECS Fargate tasks on port 8000.

Bastion Host Access: Admin access to private resources is strictly controlled via a dedicated SSH Bastion Host.

Multi-Environment Isolation: Dynamic state management using Terraform Workspaces and environment profiles (.tfvars).

💻 Tech Stack
Cloud Provider: AWS (VPC, ECS Fargate, ECR, ALB, EC2/Bastion, S3, DynamoDB, CloudWatch, IAM, Security Groups)

Infrastructure as Code: Terraform (Workspaces, S3 Backend, State Locking, Variables, Dynamic Blocks)

Containerization & DevSecOps: Docker, Trivy (Vulnerability Scanner), tfsec

CI/CD & Automation: GitHub Actions (Multi-stage YAML Workflows)

Scripting & OS: Bash, Linux (Ubuntu/WSL)

Version Control: Git & GitHub
Project Structure
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # DevSecOps CI/CD Pipeline (Lint, Scan, Build, Push)
├── app/                        # Application Source Code
│   ├── main.py                 # FastAPI microservice
│   └── requirements.txt
├── Dockerfile                  # Production Multi-Stage Dockerfile
├── backend.tf                  # S3 Remote State & DynamoDB Locking
├── ecr.tf                      # AWS ECR Repository Configuration
├── ecs.tf                      # ECS Cluster, Task Definitions & Fargate Service
├── ecs_iam.tf                  # IAM Roles for ECS Execution
├── ecs_sg.tf                   # Security Groups & Target Groups for ECS
├── load_balancer.tf            # Application Load Balancer setup
├── providers.tf                # AWS Provider configuration
├── security_groups.tf          # Network Security Groups (ALB, Bastion, App)
├── variables.tf                # Input Variables
└── vpc.tf                      # 3-Tier Network Topology
## 🚦 How to Run Locally

### 1. Clone the repository
```bash
git clone [https://github.com/Adless01/aws-secure-3tier-network.git](https://github.com/Adless01/aws-secure-3tier-network.git)
cd aws-secure-3tier-network
2. Configure AWS Credentials
Ensure you have the AWS CLI installed and configured:

Bash
aws configure
3. Initialize & Deploy Infrastructure
Bash
# Initialize backend and providers
terraform init

# Validate configuration
terraform validate

# Review deployment plan
terraform plan

# Apply infrastructure changes
terraform apply
4. Clean Up
To avoid unnecessary AWS charges, destroy resources when finished:

Bash
terraform destroy
