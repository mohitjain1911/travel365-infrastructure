output "primary_endpoint_address" { value = aws_elasticache_cluster.this.cache_nodes[0].address }
output "primary_endpoint_port" { value = aws_elasticache_cluster.this.port }
output "cluster_id" { value = aws_elasticache_cluster.this.id }
