output "ecs_cluster" {
  value = aws_ecs_cluster.my-cluster
}

output "ecs_service" {
  value = aws_ecs_service.service
}
