resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "backend" {
  name = "/ecs/${var.cluster_name}-backend"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "backend" {
  family = "${var.cluster_name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "512"
  memory = "1024"
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn

  container_definitions = jsonencode([
    {
      name = "backend"
      image = var.backend_image
      essential = true
      portMappings = [{ containerPort = 8080, hostPort = 8080, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = aws_cloudwatch_log_group.backend.name
          "awslogs-region" = var.region
          "awslogs-stream-prefix" = "backend"
        }
      }
      environment = []
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name = "${var.cluster_name}-backend"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count = var.backend_desired_count
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.subnet_ids
    security_groups = var.security_groups
    assign_public_ip = false
  }
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
}

# Similar task & service blocks for frontend and admin (omitted for brevity)
 
