resource "aws_sqs_queue" "this" {
  name = var.name
  fifo_queue = var.fifo
  tags = var.tags
}
