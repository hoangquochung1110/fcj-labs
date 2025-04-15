# AWS RDS Snapshot Management Lab

This lab demonstrates how to work with RDS snapshots in a real-world scenario, including creating snapshots, restoring from snapshots, and implementing seamless endpoint switching for applications.

## Lab Overview

In this lab, we've implemented:

1. **RDS Instance Management** - Creating and configuring an Amazon RDS MySQL database
2. **Database Snapshot Operations** - Creating and restoring from snapshots
3. **Endpoint Switching** - Implementing a strategy for switching database endpoints without application downtime

## Key Components

- **Primary RDS Instance**: Regular MySQL database (`fcj-management-db-instance`)
- **Restored RDS Instance**: Database restored from snapshot (`fcj-management-db-instance-restore`)
- **Node.js Application**: Web application connecting to the database
- **Database Initialization Scripts**: SQL scripts for creating tables and populating data

## Snapshot and Restore Process

### Creating a Snapshot

The primary RDS instance is configured to create a final snapshot when deleted:

```terraform
resource "aws_db_instance" "mysql" {
  # ... other configuration ...
  skip_final_snapshot = false
  final_snapshot_identifier = "lab-06-db-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
}
```

Manual snapshots can also be created through:
- AWS Console
- AWS CLI: `aws rds create-db-snapshot --db-instance-identifier fcj-management-db-instance --db-snapshot-identifier manual-snapshot-name`
- Terraform: Using the `aws_db_snapshot` resource

### Restoring from a Snapshot

We restored a database from a snapshot using Terraform:

```terraform
resource "aws_db_instance" "mysql_restore" {
  # ... configuration ...
  identifier = "fcj-management-db-instance-restore"
  # ... other parameters ...
}
```

The existing restoration instance is imported into Terraform state:
```
terraform import -var-file=dev.tfvars aws_db_instance.mysql_restore fcj-management-db-instance-restore
```

## Endpoint Switching Strategy

Our application can switch between database endpoints without interruption by:

1. **Environment Variables**: The application reads database connection details from environment variables
2. **Endpoint Information**: Both database endpoints are available as Terraform outputs:
   ```terraform
   output "mysql_info" { ... }
   output "mysql_restore_info" { ... }
   ```
3. **Seamless Switching**: By updating the environment variables or application configuration, we can switch database endpoints without redeploying the application

### Implementation Steps

1. **Create Initial Database**: Deploy the RDS instance via Terraform
2. **Initialize Database**: Run initialization scripts to create tables and insert data
3. **Create Snapshot**: Generate a point-in-time snapshot of the database
4. **Restore from Snapshot**: Deploy a second RDS instance from the snapshot
5. **Test Connectivity**: Verify application connects to the restored database
6. **Switch Endpoints**: Update application configuration to use the new endpoint

## Database Initialization

We've implemented a flexible database initialization approach:

1. SQL scripts for creating tables and populating data
2. Helper scripts to execute SQL against either RDS instance
3. Documentation for DevOps teams to run the initialization

## Checking Application Status

You can verify the application's database connection using:

```bash
# Check if the application is running on port 5000
lsof -i :5000

# Check application logs
cat /home/ec2-user/app_start.log

# Test application connectivity
curl http://localhost:5000
```

## Benefits of This Approach

1. **Disaster Recovery**: Quickly restore from snapshots in case of database corruption
2. **Database Migration**: Test new database configurations without affecting production
3. **Performance Testing**: Compare performance between different instance types
4. **Zero-Downtime Upgrades**: Switch to upgraded database instances without interrupting service

## Future Improvements

- Implement automatic failover between primary and secondary databases
- Add monitoring for database performance and snapshot status
- Create automated scripts for routine snapshot creation and validation 