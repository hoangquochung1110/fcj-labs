#!/bin/bash
set -e  # Exit on any error
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log all output

# Update system and install dependencies
sudo yum update -y
sudo yum install git -y
sudo dnf install mariadb105 -y

# Create a default user (ec2-user is typically default on Amazon Linux)
export USER_HOME=/home/ec2-user

# Install NVM as ec2-user
sudo -u ec2-user bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash'

# Load NVM and install Node.js (as ec2-user)
sudo -u ec2-user bash -c '
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
npm install -g pm2
'

# Clone and setup application
sudo -u ec2-user bash -c '
git clone https://github.com/hoangquochung1110/000004-EC2.git
cd 000004-EC2
npm install
'