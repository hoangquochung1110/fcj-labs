# Bài thực hành Quản lý Snapshot RDS AWS

Bài thực hành này minh họa cách làm việc với snapshot RDS trong kịch bản thực tế, bao gồm việc tạo snapshot, khôi phục từ snapshot và triển khai chuyển đổi endpoint liền mạch cho các ứng dụng.

## Tổng quan Bài thực hành

Trong bài thực hành này, chúng ta đã triển khai:

1. **Quản lý Instance RDS** - Tạo và cấu hình cơ sở dữ liệu MySQL Amazon RDS
2. **Thao tác Snapshot Cơ sở dữ liệu** - Tạo và khôi phục từ snapshot
3. **Chuyển đổi Endpoint** - Triển khai chiến lược chuyển đổi endpoint cơ sở dữ liệu mà không làm gián đoạn ứng dụng

## Các thành phần chính

- **Instance RDS Chính**: Cơ sở dữ liệu MySQL thông thường (`fcj-management-db-instance`)
- **Instance RDS Khôi phục**: Cơ sở dữ liệu được khôi phục từ snapshot (`fcj-management-db-instance-restore`)
- **Ứng dụng Node.js**: Ứng dụng web kết nối với cơ sở dữ liệu
- **Script Khởi tạo Cơ sở dữ liệu**: Script SQL để tạo bảng và điền dữ liệu

## Quy trình Snapshot và Khôi phục

### Tạo Snapshot

Instance RDS chính được cấu hình để tạo snapshot cuối cùng khi bị xóa:

```terraform
resource "aws_db_instance" "mysql" {
  # ... cấu hình khác ...
  skip_final_snapshot = false
  final_snapshot_identifier = "lab-06-db-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
}
```

Các snapshot thủ công cũng có thể được tạo thông qua:
- AWS Console
- AWS CLI: `aws rds create-db-snapshot --db-instance-identifier fcj-management-db-instance --db-snapshot-identifier manual-snapshot-name`
- Terraform: Sử dụng resource `aws_db_snapshot`

### Khôi phục từ Snapshot

Chúng ta đã khôi phục cơ sở dữ liệu từ snapshot bằng Terraform:

```terraform
resource "aws_db_instance" "mysql_restore" {
  # ... cấu hình ...
  identifier = "fcj-management-db-instance-restore"
  # ... tham số khác ...
}
```

Instance khôi phục hiện có được import vào Terraform state:
```
terraform import -var-file=dev.tfvars aws_db_instance.mysql_restore fcj-management-db-instance-restore
```

## Chiến lược Chuyển đổi Endpoint

Ứng dụng của chúng ta có thể chuyển đổi giữa các endpoint cơ sở dữ liệu mà không bị gián đoạn bằng cách:

1. **Biến Môi trường**: Ứng dụng đọc thông tin kết nối cơ sở dữ liệu từ biến môi trường
2. **Thông tin Endpoint**: Cả hai endpoint cơ sở dữ liệu đều có sẵn dưới dạng output Terraform:
   ```terraform
   output "mysql_info" { ... }
   output "mysql_restore_info" { ... }
   ```
3. **Chuyển đổi Liền mạch**: Bằng cách cập nhật biến môi trường hoặc cấu hình ứng dụng, chúng ta có thể chuyển đổi endpoint cơ sở dữ liệu mà không cần triển khai lại ứng dụng

### Các bước Triển khai

1. **Tạo Cơ sở dữ liệu Ban đầu**: Triển khai instance RDS qua Terraform
2. **Khởi tạo Cơ sở dữ liệu**: Chạy script khởi tạo để tạo bảng và nhập dữ liệu
3. **Tạo Snapshot**: Tạo snapshot theo thời điểm của cơ sở dữ liệu
4. **Khôi phục từ Snapshot**: Triển khai instance RDS thứ hai từ snapshot
5. **Kiểm tra Kết nối**: Xác minh ứng dụng kết nối với cơ sở dữ liệu đã khôi phục
6. **Chuyển đổi Endpoint**: Cập nhật cấu hình ứng dụng để sử dụng endpoint mới

## Khởi tạo Cơ sở dữ liệu

Chúng ta đã triển khai cách tiếp cận khởi tạo cơ sở dữ liệu linh hoạt:

1. Script SQL để tạo bảng và điền dữ liệu
2. Script hỗ trợ để thực thi SQL đối với một trong hai instance RDS
3. Tài liệu cho đội DevOps để chạy quá trình khởi tạo

## Kiểm tra Trạng thái Ứng dụng

Bạn có thể xác minh kết nối cơ sở dữ liệu của ứng dụng bằng cách:

```bash
# Kiểm tra xem ứng dụng có đang chạy trên cổng 5000 không
lsof -i :5000

# Kiểm tra log ứng dụng
cat /home/ec2-user/app_start.log

# Kiểm tra kết nối ứng dụng
curl http://localhost:5000
```

## Lợi ích của Cách tiếp cận Này

1. **Khôi phục Thảm họa**: Nhanh chóng khôi phục từ snapshot trong trường hợp hỏng cơ sở dữ liệu
2. **Di chuyển Cơ sở dữ liệu**: Kiểm tra cấu hình cơ sở dữ liệu mới mà không ảnh hưởng đến môi trường sản xuất
3. **Kiểm tra Hiệu suất**: So sánh hiệu suất giữa các loại instance khác nhau
4. **Nâng cấp Không Thời gian Chết**: Chuyển sang các instance cơ sở dữ liệu đã nâng cấp mà không gián đoạn dịch vụ

## Cải tiến Tương lai

- Triển khai tự động chuyển đổi dự phòng giữa cơ sở dữ liệu chính và phụ
- Thêm giám sát hiệu suất cơ sở dữ liệu và trạng thái snapshot
- Tạo script tự động để tạo và xác nhận snapshot định kỳ 