resource "aws_ecs_cluster" "ims_app" {
  name = "ims-app"
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
          value = "jdbc:postgresql://${var.rds_endpoint}:5432/your-database-name"
        },
        {
          name = "POSTGRES_DB"
          value = "your-database-name"
        },
        {
          name  = "POSTGRES_USERNAME"
          value = "your-username"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = "your-password"
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
  desired_count = 2
  platform_version = "1.3.0"
  launch_type = "FARGATE"
  health_check_grace_period_seconds =60

  network_configuration {
    assign_public_ip = false
    security_groups = [module.ims_app_sg.security_group_id]
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


