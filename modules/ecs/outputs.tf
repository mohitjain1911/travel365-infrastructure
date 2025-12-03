output "cluster_arn" { value = aws_ecs_cluster.this.arn }
output "cluster_id" { value = aws_ecs_cluster.this.id }

# Export ECS service ids. Use *_id to avoid confusion with ARN attributes
# Use conditional indexing when resources use count to avoid referencing empty lists
output "backend_service_id" { value = length(aws_ecs_service.backend) > 0 ? aws_ecs_service.backend[0].id : "" }
output "frontend_service_id" { value = length(aws_ecs_service.frontend) > 0 ? aws_ecs_service.frontend[0].id : "" }
output "admin_service_id" { value = length(aws_ecs_service.admin) > 0 ? aws_ecs_service.admin[0].id : "" }
