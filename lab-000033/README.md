# AWS S3 Encryption with CloudTrail and Athena Infrastructure

## Tổng quan về dự án

Dự án này triển khai một hệ thống cơ sở hạ tầng trên AWS với các tính năng chính:
- Mã hóa dữ liệu trong S3 sử dụng KMS (Key Management Service)
- Ghi lại tất cả hoạt động API thông qua CloudTrail
- Cho phép truy vấn dữ liệu sử dụng Amazon Athena

## Mục đích và ý nghĩa

Dự án nhằm mục đích:
1. **Bảo mật dữ liệu**: Đảm bảo dữ liệu được mã hóa an toàn trong S3
2. **Theo dõi hoạt động**: Ghi lại mọi hoạt động truy cập và thay đổi dữ liệu
3. **Phân tích dữ liệu**: Cho phép truy vấn và phân tích dữ liệu một cách hiệu quả
4. **Tuân thủ quy định**: Đáp ứng các yêu cầu về bảo mật và kiểm toán

## Các thành phần chính

### 1. Key Management Service (KMS)
- Khóa mã hóa đối xứng cho S3
- Tự động luân chuyển khóa hàng năm
- Quản lý quyền truy cập khóa

### 2. Amazon S3
- Bucket dữ liệu chính với mã hóa SSE-KMS
- Bucket kết quả truy vấn Athena
- Bucket lưu trữ CloudTrail logs

### 3. AWS CloudTrail
- Ghi lại tất cả hoạt động API
- Hỗ trợ nhiều region
- Xác thực file log
- Mã hóa dữ liệu log

### 4. Amazon Athena
- Workgroup phân tích dữ liệu
- Database cho CloudTrail logs
- Khả năng truy vấn dữ liệu đã mã hóa

## Công nghệ sử dụng

- **Infrastructure as Code**: Terraform
- **Cloud Provider**: Amazon Web Services (AWS)
- **Các dịch vụ AWS**:
  - Amazon S3
  - AWS KMS
  - AWS CloudTrail
  - Amazon Athena
  - AWS IAM

## Cấu trúc dự án

```
.
├── main.tf           # File cấu hình Terraform chính
├── variables.tf      # Định nghĩa các biến
├── s3.tf            # Cấu hình S3 buckets
├── iam.tf           # Cấu hình IAM roles và policies
├── kms.tf           # Cấu hình KMS keys
├── outputs.tf       # Định nghĩa outputs
├── dev.tfvars       # Giá trị biến cho môi trường dev
└── INFRA.md         # Tài liệu chi tiết về cơ sở hạ tầng
```

## Bảo mật

- Mã hóa dữ liệu ở trạng thái nghỉ (at-rest) với SSE-KMS
- Mã hóa dữ liệu trong quá trình truyền (in-transit) với TLS
- Kiểm soát truy cập dựa trên vai trò (RBAC)
- Yêu cầu MFA cho người dùng
- Giám sát hoạt động thông qua CloudTrail
- Luân chuyển khóa KMS định kỳ

## Chi phí ước tính

- KMS key: $1/tháng cho mỗi khóa
- S3 storage: Dựa trên khối lượng dữ liệu
- CloudTrail: Dựa trên số lượng sự kiện
- Athena: $5 cho mỗi TB dữ liệu được quét

## Hướng dẫn triển khai

1. Cài đặt Terraform
2. Cấu hình AWS credentials
3. Chỉnh sửa file `dev.tfvars` với các giá trị phù hợp
4. Chạy các lệnh Terraform:
   ```bash
   terraform init
   terraform plan -var-file="dev.tfvars"
   terraform apply -var-file="dev.tfvars"
   ```
