locals { name = "${var.app_name}-${var.environment}" }

module "vpc" {
  source               = "../../modules/vpc"
  name                 = local.name
  cidr                 = "10.10.0.0/16"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat           = true  # Enable NAT Gateway for ECR access
  region               = "eu-west-2"
}

resource "aws_security_group" "ecs" {
  name   = "${local.name}-ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Allow backend traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "${local.name}-assets-${random_id.bucket_hex.hex}"
  name        = "${local.name}-assets"
}
resource "random_id" "bucket_hex" {
  byte_length = 3
}

module "iam" {
  source    = "../../modules/iam"
  name      = local.name
  s3_bucket = module.s3.bucket
}

# No RDS in dev
# Create Redis for dev if you want (optional). For now we create Elasticache as per request.
resource "aws_security_group" "redis" {
  name   = "${local.name}-redis-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "redis" {
  source      = "../../modules/elasticache"
  name        = local.name
  subnet_ids  = module.vpc.private_subnet_ids
  redis_sg_id = aws_security_group.redis.id
  node_type   = "cache.t4g.micro"
}

module "ecs" {
  source                 = "../../modules/ecs"
  name                   = local.name
  cluster_name           = "${local.name}-cluster"
  backend_image          = var.backend_image
  frontend_image         = var.frontend_image
  admin_image            = var.admin_image
  subnet_ids             = module.vpc.private_subnet_ids
  security_groups        = [aws_security_group.ecs.id]
  execution_role_arn     = module.iam.ecs_task_exec_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn
  backend_desired_count  = 1
  frontend_desired_count = 1
  admin_desired_count    = 0
  target_group_arns      = module.alb.target_group_arns
}

resource "aws_security_group" "alb" {
  name   = "${local.name}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "alb" {
  source             = "../../modules/alb"
  name               = local.name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]
  target_groups = {
    frontend = {
      tg_name     = "t365-dev-frontend-tg"
      port        = 80
      health_path = "/"
      target_type = "ip"
    }
    backend = {
      tg_name     = "t365-dev-backend-tg"
      port        = 8080
      health_path = "/api/health"
      target_type = "ip"
    }
  }
}
