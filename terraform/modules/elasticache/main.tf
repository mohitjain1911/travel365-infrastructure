resource "aws_elasticache_subnet_group" "this" {
  name = "${var.name}-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "this" {
  cluster_id = "${var.name}-redis"
  engine = "redis"
  engine_version = var.engine_version
  node_type = var.node_type
  num_cache_nodes = 1
  subnet_group_name = aws_elasticache_subnet_group.this.name
  parameter_group_name = "default.redis7"
  port = 6379
  security_group_ids = [var.redis_sg_id]
  tags = { Name = "${var.name}-redis" }
}

 
