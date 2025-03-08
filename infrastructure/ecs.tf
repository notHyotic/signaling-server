resource "aws_ecs_cluster" "main" {
  name = "signaling-server-service-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "signaling-server-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # This ensures it's Fargate compatible
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name   = "my-container"
    image  = "${aws_ecr_repository.my_repo.repository_url}:latest"
    memory = 512
    cpu    = 256

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/my-task-logs" # Log group name
        "awslogs-region"        = "us-east-1"         # Your region
        "awslogs-stream-prefix" = "my-container"      # Log stream prefix
      }
    }

    portMappings = [
      {
        containerPort = 8080 # Container is listening on port 8080
        protocol      = "tcp"
      }
    ]

    secrets = [
      {
        name      = "LIVEKIT_API_KEY"             # Name of the environment variable
        valueFrom = aws_ssm_parameter.api_key.arn # Reference to the SSM Parameter ARN
      },
      {
        name      = "LIVEKIT_API_SECRET"             # Name of the environment variable
        valueFrom = aws_ssm_parameter.api_secret.arn # Reference to the SSM Parameter ARN
      },
      {
        name      = "LIVEKIT_WS_URL"                    # Name of the environment variable
        valueFrom = aws_ssm_parameter.websocket_url.arn # Reference to the SSM Parameter ARN
      }
    ]
  }])
}

resource "aws_ecs_service" "main" {
  name            = "signaling-server-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 2
  launch_type     = "FARGATE" # Or "EC2" if you're using EC2 instances

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "my-container"
    container_port   = 8080 # The port your container is listening on
  }

  network_configuration {
    subnets          = [aws_subnet.subnet_a.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_appautoscaling_target" "my_scaling_target" {
  max_capacity       = 3 # Max number of tasks
  min_capacity       = 1 # Min number of tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "scale-up-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.my_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.my_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.my_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0 # Target CPU utilization (%)
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60 # Wait time before scaling down
    scale_out_cooldown = 60 # Wait time before scaling up
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "scale-down-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.my_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.my_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.my_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 30.0 # Target CPU utilization (%)
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60 # Wait time before scaling down
    scale_out_cooldown = 60 # Wait time before scaling up
  }
}


