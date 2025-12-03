data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_policy" "app_policy" {
  name = "${var.name}-app-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["s3:GetObject","s3:PutObject"], Resource = ["arn:aws:s3:::${var.s3_bucket}/*"] },
      { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = ["*"] },
      { Effect = "Allow", Action = ["ses:SendEmail","ses:SendRawEmail"], Resource = ["*"] }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.app_policy.arn
}


