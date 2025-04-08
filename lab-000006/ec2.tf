resource "aws_security_group" "fcj_management_sg" {
  name        = "FCJ-Management-SG"
  description = "Security Group for FCJ Management"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-web-sg"
  }
}

# Learn our public IP address
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.fcj_management_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.fcj_management_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.fcj_management_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_custom_tcp" {
  security_group_id = aws_security_group.fcj_management_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.fcj_management_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "fcj_management_db_sg" {
  name        = "FCJ-Management-DB-SG"
  description = "Security Group for DB instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-web-sg"
  }
}

# outbound rule for fcj_management_db_sg
resource "aws_vpc_security_group_egress_rule" "allow_all_2" {
  security_group_id = aws_security_group.fcj_management_db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id            = aws_security_group.fcj_management_db_sg.id
  referenced_security_group_id = aws_security_group.fcj_management_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}


data "aws_key_pair" "devkey" {
  key_name = "fcj"
}

resource "aws_instance" "fcj_management_instance" {
  ami           = local.ami
  instance_type = local.instance_type

  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.fcj_management_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.devkey.key_name

  user_data = file("user-data.sh")

  tags = local.tags
}

resource "aws_lb_target_group" "fcj_management_tg" {
  name = "FCJ-Management-TG"

  port             = 5000
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  ip_address_type  = "ipv4"

  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

# register targets


resource "aws_launch_template" "fcj_management_instance_template" {
  name          = "FCJ-Management-AMI"
  image_id      = local.ami
  instance_type = local.instance_type
  user_data     = base64encode(file("user-data.sh"))
  key_name      = data.aws_key_pair.devkey.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "fcj_management_asg" {
  name                = "FCJ-Management-ASG"
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.fcj_management_instance_template.id
    version = aws_launch_template.fcj_management_instance_template.latest_version
  }
  
  target_group_arns = [aws_lb_target_group.fcj_management_tg.arn]
  
  min_size         = 1
  max_size         = 3
}

resource "aws_lb" "fcj_management_lb" {
  name               = "FCJ-Management-LB"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [aws_security_group.fcj_management_sg.id]
  subnets         = aws_subnet.public[*].id
}

resource "aws_lb_listener" "fcj_management_lb_listener" {
  load_balancer_arn = aws_lb.fcj_management_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fcj_management_tg.arn
  }
}

output "ec2_instance_info" {
  value = {
    public_ip = aws_instance.fcj_management_instance.public_ip
  }
}

resource "aws_autoscaling_policy" "fcj_management_asg_scale_policy" {
  name                      = "Request Over 500 per target"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  enabled                   = false
  adjustment_type           = "ExactCapacity"

  autoscaling_group_name = aws_autoscaling_group.fcj_management_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.fcj_management_lb.arn_suffix}/${aws_lb_target_group.fcj_management_tg.arn_suffix}"
    }
    target_value = 500.0
  }
}
