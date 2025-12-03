 

resource "aws_lb" "alb" {
  name = "${var.name}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = var.security_group_ids
  subnets = var.public_subnet_ids
  enable_deletion_protection = false
  tags = { Name = "${var.name}-alb" }
}

# Create listeners and rules as per target_groups map (expects map like { backend = { port=80, tg_name="..." }, ... })
resource "aws_lb_target_group" "tgs" {
  for_each = var.target_groups
  name = each.value.tg_name
  port = each.value.port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check {
    path = each.value.health_path
    protocol = "HTTP"
    matcher = "200-399"
  }
}

 

