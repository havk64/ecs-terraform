locals {
  cluster_name = "${var.prefix_name}-${var.environment}"
}

resource "aws_security_group" "ec2" {
  description = "EC2 Security Group"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr_block
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
  vpc_id      = var.vpc_id
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
  vpc_zone_identifier       = var.public_subnet_ids
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
