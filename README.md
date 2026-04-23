\# 🛡️ AegisGil - Automated SOAR System



Dự án cá nhân tập trung vào việc tự động hóa phản ứng an ninh (Security Orchestration, Automation, and Response) kết hợp giữa \*\*pfSense NGFW\*\*, \*\*n8n\*\*, và các công cụ bảo mật.



\## 🚀 Hướng dẫn triển khai (Deployment Guide)



\### 1. Yêu cầu hệ thống (Prerequisites)

\*\*\*Docker Desktop\*\*: Cần thiết để chạy các Container.

\*\*\*WSL 2\*\*: Khuyến nghị cài đặt để Docker chạy mượt hơn trên Windows.



\### 2. Cài đặt n8n (Automation Hub)

Sử dụng Docker Compose để triển khai n8n tại `localhost:5678`.

\*\*\*Timezone\*\*: Asia/Ho\_Chi\_Minh.

\*\*\*Volumes\*\*: Lưu trữ dữ liệu tại `./n8n\_data`.



\### 3. Cấu hình pfSense REST API

Để n8n có thể điều khiển Firewall, cần thiết lập:

\*\*\*Admin Access\*\*: Chỉnh `Max Processes` thành 8 và bật `WebGUI Login Autocomplete`.

\*\*\*Networking\*\*: Tắt (Disable) các mục `Hardware Checksum/TCP/Large Receive Offloading`.

\*\*\*REST API v2\*\*: Cài đặt package qua lệnh `pkg-static add` \[cite: 10] \[cite\_start]và tạo API Key riêng.



\---



\## ⚙️ Quy trình tự động hóa (n8n Workflows)



Dự án sử dụng các phương thức REST API để quản lý Alias trên pfSense:

\*\*\*GET\*\*: Kiểm tra danh sách và ID của các Alias hiện có.

\*\*\*POST\*\*: Khởi tạo danh sách đen (SOAR\_Blacklist) và thêm IP mới.

\*\*\*PATCH\*\*: Cập nhật/Nhồi thêm IP vào danh sách đã tồn tại thông qua ID.

\*\*\*APPLY\*\*: Kích hoạt các thay đổi để có hiệu lực trên Firewall (Chạy 1 lần duy nhất sau khi cập nhật).



\---



\## 🛡️ Chính sách bảo mật (Firewall Rules)



Sau khi nhồi IP vào `SOAR\_Blacklist`, hệ thống sẽ thực thi chặn tại:

1.\*\*WAN\*\*: Chặn (Block/Reject) mọi gói tin từ nguồn trong Blacklist đến hệ thống.

2.\*\*LAN\*\*: Ngăn chặn máy nội bộ kết nối đến các IP xấu trong Blacklist.

