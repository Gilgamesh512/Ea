# EA — Centralized Logging (Grafana Loki & Alloy)

Hệ thống thu thập và hiển thị log tập trung của nền tảng **EA**. Hứng Syslog thời gian thực từ tường lửa pfSense (hoặc Suricata/Snort), lưu trữ vào Loki và trực quan hóa trên Grafana Dashboard.

---

## 1. Khởi chạy nhanh

Đứng tại thư mục này và khởi chạy:

```bash
docker compose up -d
```

- **Grafana WebUI:** `http://localhost:3000` (User: `admin` / Password: `admin`)
- **Alloy Management UI:** `http://localhost:12345`
- **Loki Push API:** `http://localhost:3100/loki/api/v1/push`
- **Cổng hứng Syslog UDP:** `0.0.0.0:1514/udp`

---

## 2. Kiến trúc Thu nhận Log

```text
[pfSense Firewall / Suricata]
              │
              │ Syslog qua UDP cổng 1514
              ▼
[Grafana Alloy (ea-alloy)]
              │
              │ Đẩy qua HTTP API
              ▼
[Grafana Loki (ea-loki)]  <--->  Lưu trữ cố định tại ./loki-data/
              │
              ▼
[Grafana Dashboard (ea-grafana)]  <--->  Lưu Dashboard tại ./grafana-data/
```

- **Tính bền vững của dữ liệu:** Log được lưu cố định tại thư mục `./loki-data/`, đảm bảo khi restart container không bị mất dữ liệu.
- **Cấu hình Alloy (`config.alloy`):** Tự động gắn nhãn log `job="pfsense"`, `project="EA"`, `component="firewall"`.

---

## 3. Cấu hình pfSense gửi Log về Alloy

1. Trên WebGUI pfSense, vào mục **Status** -> **System Logs** -> **Settings**.
2. Kéo xuống mục **Remote Logging Options**:
   - Tích chọn: **Enable Remote Logging**.
   - **Source Address:** Chọn Interface kết nối với máy chủ EA.
   - **Remote log servers:** Điền `<IP_MAY_EA>:1514`.
   - **Remote Syslog Contents:** Tích chọn Firewall Events, Snort/Suricata Events.
3. Bấm **Save**.
