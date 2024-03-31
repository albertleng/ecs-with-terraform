provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "albert_ecs_cluster" {
  name = "${var.project_name}-ecs-cluster-terraform"
}

resource "aws_ecs_task_definition" "albert_ecs_task_definition" {
  family                   = "${var.project_name}TaskDefinitionTerraform"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions    = jsonencode([
    {
      name         = "NGINX"
      image        = "nginx:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "albert_ecs_service" {
  name            = "${var.project_name}ServiceTerraform"
  cluster         = aws_ecs_cluster.albert_ecs_cluster.id
  task_definition = aws_ecs_task_definition.albert_ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.albert_lb_target_group.arn
    container_name   = "NGINX"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.albert_lb_listener]
}

resource "aws_lb" "albert_lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "albert_lb_target_group" {
  name        = "${var.project_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "albert_lb_listener" {
  load_balancer_arn = aws_lb.albert_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albert_lb_target_group.arn
  }
}

#resource "aws_autoscaling_group" "albert_asg" {
#  name                 = "${var.project_name}-asg"
#  max_size             = 3
#  min_size             = 1
#  desired_capacity     = 2
#  vpc_zone_identifier  = var.subnet_ids
#  target_group_arns    = [aws_lb_target_group.albert_lb_target_group.arn]
#  launch_configuration = aws_launch_configuration.albert_lc.name
#}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.albert_ecs_cluster.name}/${aws_ecs_service.albert_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "albertAutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}


#resource "aws_launch_configuration" "albert_lc" {
#  name            = "${var.project_name}-lc"
#  image_id        = "ami-0c101f26f147fa7fd"
#  instance_type   = "t2.micro"
#  security_groups = [var.security_group_id]
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}