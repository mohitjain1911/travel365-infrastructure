# Travel365 Infrastructure

> AWS infrastructure as code for the Travel365 application platform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

## 📋 Overview

This repository contains Terraform infrastructure code for deploying the Travel365 application on AWS. It provides a modular, environment-based infrastructure setup supporting development and production environments.

### Architecture

The infrastructure deploys a containerized application using AWS ECS Fargate with the following components:

- **VPC** with public/private subnets across multiple availability zones
- **Application Load Balancer (ALB)** for traffic distribution
- **ECS Fargate** for running containerized applications (frontend, backend, admin)
- **ElastiCache Redis** for caching and session management
- **S3** for static asset storage
- **ECR** for Docker image storage (managed manually)
- **CloudWatch** for logging and monitoring
- **NAT Gateway** for private subnet internet access

## 🏗️ Repository Structure

```
travel365-infrastructure/
├── environments/          # Environment-specific configurations
│   ├── development/      # Development environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── backend.tf
│   └── production/       # Production environment
│       └── ...
├── modules/              # Reusable Terraform modules
│   ├── vpc/             # VPC, subnets, routing
│   ├── alb/             # Application Load Balancer
│   ├── ecs/             # ECS cluster and services
│   ├── elasticache/     # Redis cluster
│   ├── s3/              # S3 buckets
│   ├── iam/             # IAM roles and policies
│   ├── rds/             # Relational Database (prod only)
│   ├── sqs/             # Message queuing (prod only)
│   ├── cloudfront/      # CDN (prod only)
│   ├── route53_acm/     # DNS and SSL (prod only)
│   ├── waf/             # Web Application Firewall (prod only)
│   └── ses/             # Email service (prod only)
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with necessary permissions
- Docker images pushed to ECR

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd travel365-infrastructure
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and region (eu-west-2)
   ```

3. **Navigate to your environment**
   ```bash
   cd environments/development
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Review the plan**
   ```bash
   terraform plan -var "frontend_image=<your-ecr-image-uri>"
   ```

6. **Apply the infrastructure**
   ```bash
   terraform apply -var "frontend_image=<your-ecr-image-uri>"
   ```

## 🔧 Configuration

### Environment Variables

Each environment requires specific variables. Key variables include:

| Variable | Description | Example |
|----------|-------------|---------|
| `frontend_image` | ECR URI for frontend Docker image | `105407205785.dkr.ecr.eu-west-2.amazonaws.com/travel365/dev_frontend:abc123` |
| `backend_image` | ECR URI for backend Docker image | `105407205785.dkr.ecr.eu-west-2.amazonaws.com/travel365/dev_backend:abc123` |
| `admin_image` | ECR URI for admin Docker image | `105407205785.dkr.ecr.eu-west-2.amazonaws.com/travel365/dev_admin:abc123` |
| `app_name` | Application name | `travel365` |
| `environment` | Environment name | `development` or `production` |
| `region` | AWS region | `eu-west-2` |

### Development vs Production

#### Development Environment
- **NAT Gateway**: Enabled (required for ECR access)
- **RDS**: Disabled (not needed for dev)
- **SQS**: Disabled (not needed for dev)
- **CloudFront**: Disabled
- **WAF**: Disabled
- **Domain**: Uses ALB DNS name
- **SSL**: Not configured

#### Production Environment
- **NAT Gateway**: Enabled
- **RDS**: Enabled (PostgreSQL/MySQL)
- **SQS**: Enabled for async processing
- **CloudFront**: Enabled for CDN
- **WAF**: Enabled for security
- **Domain**: Custom domain with Route53
- **SSL**: ACM certificate

## 📦 Modules

### VPC Module
Creates VPC with public/private subnets, Internet Gateway, NAT Gateway, and routing tables.

**Usage:**
```hcl
module "vpc" {
  source               = "../../modules/vpc"
  name                 = "travel365-development"
  cidr                 = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
  enable_nat           = true
  region               = "eu-west-2"
}
```

### ALB Module
Creates Application Load Balancer with target groups and routing rules.

**Usage:**
```hcl
module "alb" {
  source             = "../../modules/alb"
  name               = "travel365-development"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]
  target_groups = {
    frontend = {
      tg_name     = "t365-dev-frontend-tg"
      port        = 80
      health_path = "/"
      target_type = "ip"  # Required for Fargate
    }
  }
}
```

### ECS Module
Creates ECS cluster, task definitions, and services for containerized applications.

**Usage:**
```hcl
module "ecs" {
  source             = "../../modules/ecs"
  name               = "travel365-development"
  cluster_name       = "travel365-development-cluster"
  frontend_image     = var.frontend_image
  backend_image      = var.backend_image
  subnet_ids         = module.vpc.private_subnet_ids
  security_groups    = [aws_security_group.ecs.id]
  execution_role_arn = module.iam.ecs_task_exec_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  target_group_arns  = module.alb.target_group_arns
}
```

## 🌐 Accessing the Application

### Development Environment
After deployment, access your application via the ALB DNS name:

```bash
# Get the ALB DNS name from Terraform output
terraform output alb_dns_name

# Access the application
http://<alb-dns-name>
```

### Production Environment
Access via your configured custom domain:
```
https://example.co.uk
```

## 📊 Monitoring

### CloudWatch Logs
Logs are available in CloudWatch Log Groups:
- Frontend: `/ecs/travel365-{environment}-cluster-frontend`
- Backend: `/ecs/travel365-{environment}-cluster-backend`
- Admin: `/ecs/travel365-{environment}-cluster-admin`

**View logs via CLI:**
```bash
aws logs tail /ecs/travel365-development-cluster-frontend --follow --region eu-west-2
```

### ECS Service Status
```bash
aws ecs describe-services \
  --cluster travel365-development-cluster \
  --services travel365-development-cluster-frontend \
  --region eu-west-2
```

## 🔄 CI/CD Integration

The infrastructure can be deployed automatically via GitHub Actions. See the frontend repository's workflow for an example of building Docker images and triggering deployments.

**Example workflow integration:**
```yaml
- name: Deploy with Terraform
  working-directory: infrastructure/environments/development
  run: |
    terraform init
    terraform apply -auto-approve \
      -var "frontend_image=${{ env.IMAGE_URI }}"
```

## 🛠️ Common Operations

### Update Docker Image
```bash
cd environments/development
terraform apply -var "frontend_image=<new-image-uri>"
```

### Force New ECS Deployment
```bash
# Taint the task definition to force recreation
terraform taint 'module.ecs.aws_ecs_task_definition.frontend[0]'
terraform apply
```

### Destroy Environment
```bash
cd environments/development
terraform destroy
```

## 🔐 Security

### Best Practices
- ✅ ECS tasks run in private subnets
- ✅ NAT Gateway for secure outbound internet access
- ✅ Security groups restrict traffic to ALB only
- ✅ IAM roles follow least privilege principle
- ✅ Secrets should be stored in AWS Secrets Manager (not implemented yet)
- ✅ HTTPS enabled in production (via ACM + ALB)

### Security Groups
- **ALB SG**: Allows HTTP (80) from internet
- **ECS SG**: Allows HTTP (80) and backend (8080) from ALB SG only
- **Redis SG**: Allows Redis (6379) from ECS SG only

## 🐛 Troubleshooting

### ECS Tasks Not Starting
1. Check CloudWatch logs for error messages
2. Verify Docker image exists in ECR
3. Ensure ECS task role has ECR pull permissions
4. Check security group allows ALB → ECS traffic

### ALB Returns 503 Error
1. Check ECS service has running tasks
2. Verify target health in ALB target group
3. Check security group rules
4. Review ECS task logs

### Terraform State Lock
```bash
# If state is locked and process is stuck
terraform force-unlock <lock-id>
```

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test in development environment
4. Submit a pull request

## 📄 License

[Your License Here]

## 👥 Maintainers

- DevOps Team

---

**Note**: Always review Terraform plans before applying changes to production environments.
