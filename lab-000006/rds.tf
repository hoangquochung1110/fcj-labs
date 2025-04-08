resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier        = "fcj-management-db-instance"
  instance_class    = "db.m5d.large"
  allocated_storage = 20
  engine            = "mysql"

  storage_type        = "gp3"
  skip_final_snapshot = false
  final_snapshot_identifier = "fcj-management-db-${formatdate("YYYYMMDD-HHmmss", timestamp())}"

  # Snapshot configuration
  snapshot_identifier = var.snapshot_identifier

  # initial db to create when the DB instance is created
  db_name  = "awsfcjuser"
  username = "admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.fcj_management_db_sg.id]
}

output "mysql_info" {
  value = {
    endpoint          = aws_db_instance.mysql.address
    connection_string = "mysql -h ${aws_db_instance.mysql.address} -P 3306 -u ${aws_db_instance.mysql.username} -p"
  }
}