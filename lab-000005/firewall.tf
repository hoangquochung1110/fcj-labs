resource "aws_security_group" "application_sg" {
  name        = "application-sg"
  description = "Allow standard web and SSH access"
  vpc_id      = aws_vpc.main.id  # Specify the VPC ID explicitly

  # Allow HTTP traffic
  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow HTTPS traffic
  ingress {
    description      = "HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow Custom TCP traffic on port 5000
  ingress {
    description      = "Custom TCP on port 5000 from anywhere"
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow SSH traffic
  # Consider restricting cidr_blocks for SSH to specific IPs for better security
  ingress {
    description = "SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_public_ip.response_body}/32"]
  }

  # Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Represents all protocols
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "application-sg"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database-sg"
  description = "Allow MySQL traffic from application SG"
  vpc_id      = aws_vpc.main.id  # Specify the VPC ID explicitly

  ingress {
    description     = "Allow MySQL traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Represents all protocols
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "database-security-group"
  }
}
