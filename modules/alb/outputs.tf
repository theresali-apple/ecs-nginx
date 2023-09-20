output "alb" {
  value = aws_lb.my_alb
}

output "ecs_target_group" {
  value = aws_lb_target_group.ecs
}
