output "cluster_arn" { value = aws_ecs_cluster.this.arn }
output "cluster_id" { value = aws_ecs_cluster.this.id }
output "backend_service_arn" { value = try(aws_ecs_service.backend.arn, "") }
output "frontend_service_arn" { value = try(aws_ecs_service.frontend.arn, "") }
output "admin_service_arn" { value = try(aws_ecs_service.admin.arn, "") }
