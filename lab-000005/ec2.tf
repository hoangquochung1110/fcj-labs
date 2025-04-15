data "aws_key_pair" "fcj_key_pair" {
  key_name = "fcj"
}

// use instance type t2.micro

# EC2 Instance Definition
resource "aws_instance" "app_server" {
  ami           = local.ami
  instance_type = local.instance_type
  subnet_id                   = aws_subnet.public[0].id # Place in the first public subnet
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true # Enable public IP and DNS

  # Use the existing key pair
  key_name = data.aws_key_pair.fcj_key_pair.key_name

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  # Use the external user_data.sh script
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "app-server"
  }
}

output "instance_info" {
  description = "All information about the EC2 instance"
  value = {
    id                  = aws_instance.app_server.id
    public_ip           = aws_instance.app_server.public_ip
    public_dns          = aws_instance.app_server.public_dns
    ssh_connection      = "ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip}"
    setup_log_command   = "ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip} 'cat /home/ec2-user/setup.log'"
    app_log_command     = "ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip} 'cat /home/ec2-user/app_start.log'"
  }
}

output "user_data_execution_logs" {
  description = "Information about user_data script execution logs"
  value = <<-EOF
    --------------------------------------------------------
    USER DATA EXECUTION LOGS
    --------------------------------------------------------
    To check if the user_data script executed successfully:
    
    1. Main setup log:
       $ ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip} 'cat /home/ec2-user/setup.log'
    
    2. Application startup log:
       $ ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip} 'cat /home/ec2-user/app_start.log'
    
    3. Check if Node.js is installed correctly:
       $ ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip} 'source ~/.nvm/nvm.sh && node -v && npm -v'
    
    4. Connect to the instance and view the README file:
       $ ssh -i ~/.ssh/${data.aws_key_pair.fcj_key_pair.key_name}.pem ec2-user@${aws_instance.app_server.public_ip} 'cat /home/ec2-user/README.txt'
    
    You can also access the application at:
    http://${aws_instance.app_server.public_ip}:5000
    --------------------------------------------------------
  EOF
}