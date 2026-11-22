# EA — DefectDojo Vulnerability Management

Hệ thống quản lý lỗ hổng an ninh thông tin tập trung của nền tảng **EA**. Dùng để lưu trữ, theo dõi và quản lý vòng đời xử lý các lỗ hổng (findings) từ Wazuh, SAST/DAST scanner hoặc các đợt đánh giá an ninh.

---

## 1. Khởi chạy nhanh

Triển khai cấu hình tự đóng gói (Self-contained) sử dụng official prebuilt Docker images:

```bash
docker compose up -d
```

- **Giao diện WebUI:** `http://localhost:8080` (hoặc HTTPS tại `https://localhost:8443`)
- **Tài khoản mặc định:** `admin`

---

## 2. Lấy Mật khẩu Quản trị Khởi tạo

Khi container `ea-defectdojo-initializer` chạy lần đầu, mật khẩu khởi tạo sẽ được sinh ra. Xem mật khẩu bằng lệnh:

```bash
docker logs ea-defectdojo-initializer | findstr "Admin password:"
```

*(Mật khẩu quản trị được tự động sinh ngẫu nhiên khi khởi tạo lần đầu và hiển thị trong log của container).*

---

## 3. Kiến trúc Lưu trữ & Dữ liệu Cục bộ

Toàn bộ dữ liệu của DefectDojo được phân định rõ ràng ngay tại thư mục `./data/`:

- `./data/postgres/`: Cơ sở dữ liệu quan hệ PostgreSQL 16 chứa toàn bộ người dùng, findings, engagements.
- `./data/media/`: Lưu trữ các tệp đính kèm, báo cáo PDF, chứng cứ scan.
- `./data/valkey/`: Cache và Message Broker cho Celery background tasks.

---

## 4. Tích hợp với EA SOAR (n8n)

Khi n8n cần đẩy lỗ hổng hoặc kết quả đánh giá vào DefectDojo:
- **API URL:** `http://host.docker.internal:8080/api/v2`
- **Authentication:** `Authorization: Token <DOJO_API_KEY>` (Tạo API Key trong phần Profile trên WebUI).
