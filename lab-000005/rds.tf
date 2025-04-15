# Create DB Subnet Group using existing private subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "DB subnet group for RDS instance using private subnets"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier        = "fcj-management-db-instance"
  instance_class    = "db.m5d.large"
  allocated_storage = 20
  engine            = "mysql"

  storage_type        = "gp3"
  skip_final_snapshot = false
  final_snapshot_identifier = "lab-06-db-${formatdate("YYYYMMDD-HHmmss", timestamp())}"

  # Snapshot configuration
  snapshot_identifier = var.snapshot_identifier

  # initial db to create when the DB instance is created
  db_name  = "awsfcjuser"
  username = "admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}

output "mysql_info" {
  value = {
    endpoint          = aws_db_instance.mysql.address
    connection_string = "mysql -h ${aws_db_instance.mysql.address} -P 3306 -u ${aws_db_instance.mysql.username} -p"
    DB_HOST = "${aws_db_instance.mysql.address}"
    DB_NAME = "${aws_db_instance.mysql.db_name}"
    DB_USER = "${aws_db_instance.mysql.username}"
  }
}

output "mysql_restore_info" {
  value = {
    endpoint          = aws_db_instance.mysql_restore.address
    connection_string = "mysql -h ${aws_db_instance.mysql_restore.address} -P 3306 -u ${aws_db_instance.mysql_restore.username} -p"
    DB_HOST = "${aws_db_instance.mysql_restore.address}"
    DB_NAME = "${aws_db_instance.mysql_restore.db_name}"
    DB_USER = "${aws_db_instance.mysql_restore.username}"
  }
}

# Import existing RDS instance using CLI:
# terraform import aws_db_instance.mysql_restore fcj-management-db-instance-restore
# 
# After importing, use 'terraform state show aws_db_instance.mysql_restore' to see actual attributes
# Then update this resource definition to match the real configuration
resource "aws_db_instance" "mysql_restore" {
    allocated_storage                     = 20
    auto_minor_version_upgrade            = true
    availability_zone                     = "ap-southeast-1b"
    backup_retention_period               = 0
    backup_target                         = "region"
    backup_window                         = "16:47-17:17"
    ca_cert_identifier                    = "rds-ca-rsa2048-g1"
    copy_tags_to_snapshot                 = true
    custom_iam_instance_profile           = null
    customer_owned_ip_enabled             = false
    database_insights_mode                = "standard"
    db_name                               = "awsfcjuser"
    db_subnet_group_name                  = "rds-subnet-group"
    dedicated_log_volume                  = false
    delete_automated_backups              = true
    deletion_protection                   = false
    domain                                = null
    domain_auth_secret_arn                = null
    domain_iam_role_name                  = null
    domain_ou                             = null
    enabled_cloudwatch_logs_exports       = []
    engine                                = "mysql"
    engine_version                        = "8.0.40"
    iam_database_authentication_enabled   = false
    identifier                            = "fcj-management-db-instance-restore"
    instance_class                        = "db.t3.micro"
    iops                                  = 3000
    kms_key_id                            = null
    license_model                         = "general-public-license"
    maintenance_window                    = "sun:18:44-sun:19:14"
    max_allocated_storage                 = 0
    monitoring_interval                   = 0
    monitoring_role_arn                   = null
    multi_az                              = false
    network_type                          = "IPV4"
    option_group_name                     = "default:mysql-8-0"
    parameter_group_name                  = "default.mysql8.0"
    performance_insights_enabled          = false
    performance_insights_retention_period = 0
    port                                  = 3306
    publicly_accessible                   = false
    skip_final_snapshot                   = true
    storage_throughput                    = 125
    storage_type                          = "gp3"
    username                              = "admin"
    vpc_security_group_ids                = [
        "sg-0af20f7725f78b761",
    ]
    
    lifecycle {
        ignore_changes = all
    }
}