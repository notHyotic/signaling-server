# Create the Application Load Balancer
resource "aws_lb" "my_alb" {
  name                       = "my-alb"
  internal                   = false # Set to true if it's an internal ALB
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]                   # Security group for ALB
  subnets                    = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id] # Subnets where ALB will be deployed
  enable_deletion_protection = false                                            # Set to true to prevent deletion
}

# Create a listener for the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    fixed_response {
      status_code  = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 8080 # The port your ECS tasks are listening to
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id # VPC where ECS tasks are running
  target_type = "ip"

  health_check {
    path                = "/health" # Adjust if your container has a different health check path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

