resource "aws_ecs_cluster" "my-cluster" {
  name = "my-cluster"
  capacity_providers = ["FARGATE"]
  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = "ecs-nginx"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family = "service"
  container_definitions = <<TASK_DEFINITION
  [
  {
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "cpu": 512,
    "memory": 1024,
    "image": "nginx",
    "essential": true,
    "name": "nginx"
  }
]
TASK_DEFINITION

  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = "1024"
  cpu = "512"
  execution_role_arn = var.ecs_role.arn
  task_role_arn = var.ecs_role.arn

  tags = {
    Project = "ecs-nginx"
  }
}

resource "aws_ecs_service" "service" {
  name = "service"
  cluster = aws_ecs_cluster.my-cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "LATEST"

  lifecycle {
    ignore_changes = [
      desired_count]
  }

  network_configuration {
    subnets = [
      var.ecs_subnet_a.id,
      var.ecs_subnet_b.id]
    security_groups = [
      var.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.ecs_target_group.arn
    container_name = "nginx"
    container_port = 80
  }
}
