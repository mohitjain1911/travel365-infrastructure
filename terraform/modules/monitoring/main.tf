resource "aws_cloudwatch_log_group" "app" {
  name = var.log_group_name
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name = "${var.name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"
  period      = 300
  statistic   = "Average"
  threshold   = 70
  dimensions = { ClusterName = var.cluster_name }
}

 
