locals {
  cluster_name = "${var.prefix_name}-${var.environment}"
}

module "network" {
  source = "../network"

  vpc_cidr = var.vpc_cidr // default: "10.0.0.0/16" = 10.0.0.0 => 10.0.255.255 = 65.536 nodes
  enable_dns_hostnames = true
  enable_dns_support = true
  name = local.cluster_name
  environment = var.environment
  automation_tag = var.automation_tag
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  vpc_id                  = module.vpc.id
  count                   = length(var.subnet_cidrs)
  cidr_block              = element(var.subnet_cidrs, count.index) // default: 10.0.0.0 -> 10.0.0.255 = 256
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch // default: true

  tags = {
    Name        = "${var.prefix_name}_${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.gw_id
  }
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2" {
  description = "ECS Security Group"
  vpc_id      = module.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_security_group" "lb_sg" {
  vpc_id      = module.vpc.id
  name_prefix = local.cluster_name
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

data "aws_ami" "latest_ecs_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

resource "aws_launch_configuration" "ec2" {
  image_id                    = var.aws_ami != "" ? var.aws_ami : data.aws_ami.latest_ecs_ami.image_id
  instance_type               = var.instance_type // default: t2.micro
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  security_groups             = [aws_security_group.ec2.id]
  associate_public_ip_address = var.associate_public_ip // default: true
  key_name                    = var.ssh_key_name
  user_data                   = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER="${local.cluster_name}" >> /etc/ecs/ecs.config
    EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "orchestra" {
  name                      = "asg-${local.cluster_name}"
  vpc_zone_identifier       = aws_subnet.public.*.id
  launch_configuration      = aws_launch_configuration.ec2.name
  desired_capacity          = var.ec2_desired_count
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "ecs-instance-role-${local.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_agent-${local.cluster_name}"
  role = aws_iam_role.instance_role.id
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_alb_target_group" "default" {
  name     = "alb-target-${local.cluster_name}"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = module.vpc.id
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
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb_sg.id]
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
