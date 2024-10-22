resource "aws_ecs_cluster" "ims_app" {
  name = "ims-app"
}

module "ecs_task_execution_role" {
  source = "../iam_role"
  name = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}

module "ecs_events_role" {
  source = "../iam_role"
  name = "ecs-events"
  identifier = "events.amazonaws.com"
  policy = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

data "aws_ssm_parameter" "POSTGRES_ENDPOINT" {
  name = "/ims-app/POSTGRES_ENDPOINT"
  with_decryption = true
}

data "aws_ssm_parameter" "POSTGRES_DB" {
  name = "/ims-app/POSTGRES_DB"
  with_decryption = true
}



resource "aws_ecs_task_definition" "ims_app" {
#   container_definitions = file("./container_definitions.json")
  container_definitions = jsonencode([
    {
      name  = "ims-app",
      image = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.repository_name}:app-latest",
      environment = [
        {
          name  = "POSTGRES_ENDPOINT"
          value = data.aws_ssm_parameter.POSTGRES_ENDPOINT.value
        },
        {
          name = "POSTGRES_DB"
          value = data.aws_ssm_parameter.POSTGRES_DB.value
        },
        {
          name  = "POSTGRES_USERNAME"
          value = data.aws_ssm_parameter.POSTGRES_USERNAME.value
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = data.aws_ssm_parameter.POSTGRES_PASSWORD.value
        }
      ],
      essential = true,
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/ims-app"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ims-app"
        }
      }
      portMappings = [
        {
          protocol = "tcp"
          containerPort = 8080
        }
      ]
    }
  ])
  family                = "ims-app"
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "ims_app" {
  name = "ims-app"
  cluster = aws_ecs_cluster.ims_app.arn
  task_definition = aws_ecs_task_definition.ims_app.arn
  desired_count = 1
  platform_version = "1.4.0"
  launch_type = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [module.postgres_sg.security_group_id, module.http_redirect_sg.security_group_id]
    subnets = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  }

  load_balancer {
    container_name = "ims-app"
    container_port = 8080
    target_group_arn = aws_lb_target_group.ims_app.arn
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "kms:Decrypt",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/ims-app"
  retention_in_days = 180
}


