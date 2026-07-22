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
