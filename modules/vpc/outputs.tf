output "vpc" {
  value = aws_vpc.vpc
}

output "load_balancer_subnet_a" {
  value = aws_subnet.alb_a
}

output "load_balancer_subnet_b" {
  value = aws_subnet.alb_b
}

output "ecs_subnet_a" {
  value = aws_subnet.ecs_a
}

output "ecs_subnet_b" {
  value = aws_subnet.ecs_b
}

output "load_balancer_sg" {
  value = aws_security_group.load_balancer
}

output "ecs_sg" {
  value = aws_security_group.ecs_task
}
