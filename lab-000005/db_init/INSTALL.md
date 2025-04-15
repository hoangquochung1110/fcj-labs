# Database Initialization for AWS FCJ Management

This directory contains scripts for initializing the AWS FCJ Management database with the required schema and sample data.

## Files

- `init_database.sql` - SQL script that creates tables and populates them with initial data
- `setup_database.sh` - Shell script to help connect to the RDS instance and execute the SQL script

## Instructions for DevOps

### Step 1: Copy these files to the EC2 instance

```bash
# Example using scp (adjust with your EC2 instance details)
scp -i "your-key.pem" -r db_init ec2-user@your-ec2-instance-ip:~
```

### Step 2: Connect to your EC2 instance

```bash
ssh -i "your-key.pem" ec2-user@your-ec2-instance-ip
```

### Step 3: Make the script executable

```bash
cd ~/db_init
chmod +x setup_database.sh
```

### Step 4: Execute the script with RDS details

You'll need the following information from your RDS instance:
- DB_HOST - The RDS endpoint (from Terraform output)
- DB_NAME - The database name (awsfcjuser)
- DB_USER - The database username (admin)
- DB_PASSWORD - The database password

```bash
./setup_database.sh DB_HOST DB_NAME DB_USER DB_PASSWORD
```

For example:
```bash
./setup_database.sh fcj-management-db-instance.abcdefg.us-east-1.rds.amazonaws.com awsfcjuser admin YourPassword123
```

### Verification

To verify the setup was successful, you can connect to the database and check:

```bash
mysql -h DB_HOST -u DB_USER -p DB_NAME

# Inside MySQL prompt
mysql> SHOW TABLES;
mysql> SELECT * FROM users;
mysql> SELECT * FROM tasks;
mysql> SELECT * FROM settings;
```

## Customization

Feel free to modify the `init_database.sql` script to add or modify tables and initial data as needed for your application. 