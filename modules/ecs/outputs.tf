output "cluster_arn" { value = aws_ecs_cluster.this.arn }
output "cluster_id" { value = aws_ecs_cluster.this.id }

# Export ECS service ids. Use *_id to avoid confusion with ARN attributes
output "backend_service_id" { value = try(aws_ecs_service.backend.id, "") }
output "frontend_service_id" { value = try(aws_ecs_service.frontend.id, "") }
output "admin_service_id" { value = try(aws_ecs_service.admin.id, "") }
