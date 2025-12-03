resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags = { Name = "${var.db_name}-subnet-group" }
}

resource "aws_db_instance" "this" {
  identifier = "${var.db_name}-${random_id.suffix.hex}"
  engine = "postgres"
  engine_version = "15"
  instance_class = var.instance_class
  
  username = var.username
  password = var.password
  allocated_storage = var.allocated_storage
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot = true
  publicly_accessible = false
  multi_az = false
  storage_encrypted = true
  backup_retention_period = 7
  tags = { Name = var.db_name }
}

resource "random_id" "suffix" { byte_length = 4 }

 
