#!/bin/bash
# Database initialization script for AWS FCJ Management
# Usage: ./setup_database.sh [DB_HOST] [DB_NAME] [DB_USER] [DB_PASSWORD]

# Check if all parameters are provided
if [ $# -ne 4 ]; then
  echo "Error: Missing required parameters"
  echo "Usage: ./setup_database.sh [DB_HOST] [DB_NAME] [DB_USER] [DB_PASSWORD]"
  exit 1
fi

DB_HOST=$1
DB_NAME=$2
DB_USER=$3
DB_PASSWORD=$4

# Check if mysql client is installed
if ! command -v mysql &> /dev/null; then
  echo "MySQL client not found. Installing..."
  sudo dnf install mariadb105 -y || sudo yum install mysql -y
fi

echo "Connecting to database at $DB_HOST"
echo "Using database: $DB_NAME"
echo "User: $DB_USER"

# Execute the SQL script
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < init_database.sql

if [ $? -eq 0 ]; then
  echo "✅ Database initialization completed successfully!"
else
  echo "❌ Failed to initialize database. Check the error message above."
  exit 1
fi

echo "Tables created and populated with sample data." 