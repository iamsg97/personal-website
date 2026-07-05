data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_cluster" "main" {
  name = var.project_name

  setting {
    name  = "containerInsights"
    value = "disabled" # avoid extra CloudWatch charges on a personal-project cluster
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-ecs-instance" }
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                  = "${var.project_name}-ecs"
  vpc_zone_identifier   = aws_subnet.public[*].id
  min_size              = 1
  max_size              = 1
  desired_capacity      = 1
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "main" {
  name = var.project_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.project_name
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name = "app"
      # Placeholder tag; the CD workflow registers a new revision pointing at
      # the freshly built image on every deploy (see .github/workflows/cd.yml).
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0
          protocol      = "tcp"
        }
      ]

      # NEXT_PUBLIC_SITE_URL is intentionally not set here: Next.js inlines
      # NEXT_PUBLIC_* vars at build time, so a runtime ECS env var has no
      # effect. It's passed as a Docker build-arg by the CD workflow instead
      # (see .github/workflows/cd.yml and Dockerfile).
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "PORT", value = tostring(var.container_port) },
        { name = "CONTACT_TO_EMAIL", value = var.contact_to_email },
        { name = "CONTACT_FROM_EMAIL", value = var.contact_from_email },
      ]

      secrets = [
        { name = "RESEND_API_KEY", valueFrom = aws_ssm_parameter.resend_api_key.arn },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  lifecycle {
    ignore_changes = [container_definitions] # CD pipeline owns the running image tag
  }
}

resource "aws_ecs_service" "app" {
  name    = var.project_name
  cluster = aws_ecs_cluster.main.id
  # Pin to the initial revision at apply time; the CD workflow updates the
  # service to newer revisions directly and Terraform ignores that drift.
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
  }

  # A single t3.micro instance can't run two copies of the task at once, so a
  # rolling deploy briefly stops the old task before starting the new one.
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
