#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Logging function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /home/ec2-user/setup.log
}

log "Bắt đầu cài đặt..."

# Cài đặt Git
log "Đang cài đặt Git..."
dnf update -y || { log "Không thể cập nhật gói"; exit 1; }
dnf install git -y || { log "Không thể cài đặt Git"; exit 1; }
git --version > /home/ec2-user/git_version.txt

# Tạo thư mục làm việc
log "Tạo thư mục làm việc..."
rm -rf /home/ec2-user/app  # Remove it completely first
mkdir -p /home/ec2-user/app

# Setup Node environment
log "Cài đặt môi trường Node.js..."
# Cài đặt NVM trong thư mục người dùng
export HOME="/home/ec2-user"
export USER="ec2-user"

# Clone repository
log "Đang clone repository..."
cd /home/ec2-user/app
git clone https://github.com/AWS-First-Cloud-Journey/AWS-FCJ-Management . || { log "Không thể clone repository"; exit 1; }

# Kiểm tra xem NVM đã được cài đặt chưa
if [ ! -d "$HOME/.nvm" ]; then
  log "Đang cài đặt NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi

# Đảm bảo NVM có sẵn cho script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Make sure NVM is loaded on login
log "Đảm bảo NVM khởi chạy khi đăng nhập..."
cat << 'EOF' >> /home/ec2-user/.bashrc

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

# Also add to .bash_profile for login shells
if [ ! -f /home/ec2-user/.bash_profile ] || ! grep -q "NVM Configuration" /home/ec2-user/.bash_profile; then
  cat << 'EOF' >> /home/ec2-user/.bash_profile

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
fi

# Set default Node.js version
log "Đặt Node.js mặc định..."
# Create a .nvmrc file in the home directory
echo "lts/*" > /home/ec2-user/.nvmrc
# And in the app directory
echo "lts/*" > /home/ec2-user/app/.nvmrc

# Cài đặt Node.js
log "Cài đặt Node.js..."
nvm install --lts || { log "Không thể cài đặt Node.js"; exit 1; }
nvm use --lts || { log "Không thể sử dụng Node.js LTS"; exit 1; }

# Lưu phiên bản Node và npm
node -v > /home/ec2-user/node_version.txt
npm -v > /home/ec2-user/npm_version.txt

# Đi đến thư mục dự án
cd /home/ec2-user/app

# Cài đặt các gói npm
log "Cài đặt các gói npm..."
if [ -f package.json ]; then
  npm install || { log "Không thể cài đặt các gói npm"; exit 1; }
else
  log "Không tìm thấy package.json, tạo mới..."
  npm init -y
  npm install express dotenv express-handlebars body-parser mysql || { log "Không thể cài đặt các gói npm"; exit 1; }
fi

# Cài đặt nodemon
log "Cài đặt nodemon..."
npm install --save-dev nodemon || { log "Không thể cài đặt nodemon"; exit 1; }
npm install -g nodemon || { log "Không thể cài đặt nodemon toàn cục"; exit 1; }

# Thêm kịch bản npm start nếu chưa có
if ! grep -q '"start":' package.json; then
  log "Thêm script start..."
  sed -i 's/"scripts": {/"scripts": {\n    "start": "node index.js",/' package.json || { log "Không thể cập nhật package.json"; exit 1; }
fi

# Bắt đầu ứng dụng để thử nghiệm
log "Kiểm tra ứng dụng..."
# Start the app in the background temporarily for verification
nohup npm start > /home/ec2-user/app_start.log 2>&1 &
APP_PID=$!

# Give it a moment to start
sleep 5

# Simple health check
if curl -s http://localhost:5000 > /dev/null; then
  log "✅ Ứng dụng đã khởi động thành công"
else
  log "⚠️ Ứng dụng không khởi động được, kiểm tra /home/ec2-user/app_start.log"
fi

# Stop the test process
kill $APP_PID 2>/dev/null || true

# Sửa quyền
log "Cấp quyền cho ec2-user..."
chown -R ec2-user:ec2-user /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/.nvm
chown ec2-user:ec2-user /home/ec2-user/.bashrc
chown ec2-user:ec2-user /home/ec2-user/.bash_profile
chown ec2-user:ec2-user /home/ec2-user/.nvmrc
chown ec2-user:ec2-user /home/ec2-user/node_version.txt
chown ec2-user:ec2-user /home/ec2-user/npm_version.txt
chown ec2-user:ec2-user /home/ec2-user/git_version.txt
chown ec2-user:ec2-user /home/ec2-user/setup.log
chown ec2-user:ec2-user /home/ec2-user/app_start.log

# Tạo service file cho ứng dụng (tuỳ chọn)
log "Cài đặt hoàn tất."
cat > /home/ec2-user/README.txt << 'EOF'
Ứng dụng đã được cài đặt trong thư mục /home/ec2-user/app

Cách chạy ứng dụng:
1. cd /home/ec2-user/app
2. npm start

Nếu gặp lỗi 'npm: command not found', hãy thử các cách sau:
- Thoát và đăng nhập lại để tải lại cấu hình bash
- Hoặc chạy: source ~/.bashrc
- Hoặc chạy: export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

Để kiểm tra npm đã được cài đặt: npm -v

File log để troubleshoot:
- /home/ec2-user/setup.log - Log quá trình cài đặt
- /home/ec2-user/app_start.log - Log khởi động ứng dụng
EOF
chown ec2-user:ec2-user /home/ec2-user/README.txt

log "User data script completed successfully!"
