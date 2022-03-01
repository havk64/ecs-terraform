locals {
  cluster_name = "${var.prefix_name}-${var.environment}"
}

module "network" {
  source = "../network"

  vpc_cidr                = var.vpc_cidr
  subnet_cidrs            = var.subnet_cidrs
  prefix_name             = var.prefix_name
  environment             = var.environment
  automation_tag          = var.automation_tag
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "asg" {
  source = "../asg"

  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnets.*.id
  ssh_allowed_cidr_block = var.ssh_allowed_cidr_block
  prefix_name = var.prefix_name
  environment = var.environment
  automation_tag = var.automation_tag
  aws_ami = var.aws_ami
  instance_type = var.instance_type
  associate_public_ip = var.associate_public_ip
  ssh_key_name = var.ssh_key_name
  ec2_desired_count = var.ec2_desired_count
  asg_max_size = var.asg_max_size
  asg_min_size = var.asg_min_size
}

resource "aws_alb_target_group" "default" {
  name     = "alb-target-${local.cluster_name}"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id
  health_check {
    path = var.container_healthcheck_path
  }
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_alb" "main" {
  name            = "alb-${local.cluster_name}"
  subnets         = module.network.public_subnets.*.id //before: module.network.public_subnet_ids
  security_groups = [module.asg.lb_sg_id]
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

data "aws_iam_policy_document" "assume_ecs_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service" {
  name               = "ecs-service-role-${local.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_role.json
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_iam_role_policy_attachment" "ecs_lb" {
  role       = aws_iam_role.ecs_service.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_ecs_cluster" "groover" {
  name = local.cluster_name
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_ecs_task_definition" "rocker" {
  family = var.task_family_name
  container_definitions = jsonencode([
    {
      name      = var.task_definition_name
      image     = var.container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port // default: 0
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.groover.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_cloudwatch_log_group" "groover" {
  name = "${local.cluster_name}/hello"
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_ecs_service" "hello" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.groover.id
  task_definition = aws_ecs_task_definition.rocker.arn
  desired_count   = var.ecs_desired_count // default: 5
  iam_role        = aws_iam_role.ecs_service.name
  propagate_tags  = "SERVICE"

  load_balancer {
    target_group_arn = aws_alb_target_group.default.id
    container_name   = var.task_definition_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_lb,
    aws_alb_listener.front_end,
  ]

  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}
