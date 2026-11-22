# EA — n8n SOAR Orchestration Engine

Module điều phối tự động hóa bảo mật (SOAR) cốt lõi của nền tảng **EA**. Tiếp nhận cảnh báo từ Wazuh SIEM, kích hoạt phân tích bối cảnh qua Ollama AI, kiểm tra an toàn chống chặn nhầm người nhà và tự động cập nhật tường lửa pfSense.

---

## 1. Khởi chạy nhanh

Đứng tại thư mục này và khởi chạy:

```bash
docker compose up -d
```

- **Giao diện WebUI:** `http://localhost:5678`
- **Dữ liệu lưu trữ:** Cục bộ tại `./n8n_data/` (bảo toàn SQLite database và các credential đã cấu hình).

---

## 2. Luồng Điều phối & Logic Chống Chặn Nhầm "Người Nhà"

Một vấn đề phổ biến của các giải pháp SOAR là **"tự bắn vào chân mình" (Self-Lockout)**: Khi phát sinh cảnh báo giả mạo (IP Spoofing) hoặc lỗi cấu hình nội bộ, hệ thống tự động khóa chính Gateway, máy chủ SIEM hoặc DNS.

Trong EA, workflow [ea-soar-pipeline.json](./workflows/ea-soar-pipeline.json) giải quyết triệt để vấn đề này qua chuỗi logic 4 lớp:

```text
[Wazuh Webhook / Alert]
         ↓
[Lớp 1: Anti-Lockout Filter (Code Node)]
   ├─► Nếu IP thuộc: Gateway, Wazuh, n8n, DNS, hoặc Subnet nội bộ (RFC1918)
   │     └── TỪ CHỐI CHẶN -> Ghi log bảo vệ & Báo cáo an toàn
   │
   └─► Nếu IP ngoại vi + Cảnh báo nghiêm trọng (Level >= 7)
         ↓
[Lớp 2: Ollama AI Analysis]
   └── DeepSeek-R1 / Qwen2.5 tóm tắt hành vi và đánh giá mức độ nguy hiểm
         ↓
[Lớp 3: Dynamic ID pfSense Query]
   └── Gọi GET /api/v2/firewall/aliases -> Tự động tìm ID của 'SOAR_Blacklist' (không fix cứng)
         ↓
[Lớp 4: Safe Append & Apply]
   └── Nối IP mới vào danh sách hiện tại (Không Overwrite) -> PATCH -> Apply
```

---

## 3. Cách Import Workflow vào n8n

1. Mở trình duyệt vào `http://localhost:5678`.
2. Vào mục **Workflows** -> bấm dấu `...` ở góc trên bên phải -> chọn **Import from File**.
3. Chọn file [ea-soar-pipeline.json](./workflows/ea-soar-pipeline.json).
4. Bật công tắc **Active** góc trên bên phải sang trạng thái `Bật` (Active).

---

## 4. Cách Test Luồng Dữ Liệu (Không Cần Cài Wazuh Trước)

Để người phát triển hoặc người đánh giá kiểm tra ngay luồng dữ liệu mà không cần phải triển khai sẵn cả cụm máy ảo Wazuh phức tạp:

### Chạy bằng PowerShell (Windows):
```powershell
.\test-soar-pipeline.ps1
```

### Chạy bằng Bash (Linux/macOS):
```bash
chmod +x test-soar-pipeline.sh
./test-soar-pipeline.sh
```

### Kịch bản kiểm thử:
- **Test Case 1 (Kẻ tấn công ngoài Internet):** Gửi cảnh báo brute-force từ IP `203.0.113.195` -> n8n kích hoạt phân tích AI -> Tra cứu ID pfSense -> Thêm vào Blacklist thành công.
- **Test Case 2 (Người nhà / IP Gateway):** Gửi cảnh báo từ IP `192.168.2.1` -> Bộ lọc an toàn kích hoạt -> **Từ chối chặn** -> Giữ nguyên kết nối mạng thông suốt.
