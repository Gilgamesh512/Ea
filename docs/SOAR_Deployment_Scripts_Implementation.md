1. Cai Docker Desktop

Sau khi cai truy cap vao trang Web: https://learn.microsoft.com/en-us/windows/wsl/basic-commands
Thuc hien lenh cai tren Host

wsl --install or wsl --list --online

or

Truy cập vào https://github.com/microsoft/WSL/releases
Tải file wsl.2.6.3.0.x64.msi
Và khởi chạy nó


2. Cai n8n

docker run -d `
  --name n8n_soar_system `
  -p 5678:5678 `
  -v n8n_data:/home/node/.n8n `
  -e GENERIC_TIMEZONE=Asia/Ho_Chi_Minh `
  -e TZ=Asia/Ho_Chi_Minh `
  --restart always `
  n8nio/n8n

 or

Tạo 1 file docker-compose.yml chuẩn YML chèn đoạn lệnh sao

version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n_soar_system
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=localhost
      - NODE_ENV=production
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - TZ=Asia/Ho_Chi_Minh
    volumes:
      - ./n8n_data:/home/node/.n8n

Sau đó cd đến thư mục muốn lưu n8n
Rồi chạy docker-compose up -d

Thử truy cập vào localhost:5678

Sau khi cai kiem tra Docker Desktop da co n8n chua hoac truy cap http://localhost:5678

3. Cai Rest API

Truy cap vao trang Web: https://github.com/pfrest/pfSense-pkg-RESTAPI

Sau đo lay link cai đat cho REST API v2:
pkg-static add https://github.com/pfrest/pfSense-pkg-RESTAPI/releases/latest/download/pfSense-2.8.1-pkg-RESTAPI.pkg

pkg add pfSense-2.8.1-pkg-RESTAPI.pkg

Thuc hien lenh tren Host

PowerShell Admin
curl.exe -k -X GET "https://192.168.2.1/api/v2/diagnostics/arp_table" `
         -H "x-api-key: YOUR_PFSENSE_API_KEY"



# Bước này để bỏ qua lỗi SSL (Chỉ cần chạy 1 lần trong phiên làm việc)
# Phải chạy dòng này đầu tiên trong mỗi phiên làm việc PowerShell, nếu không mấy lệnh bên dưới sẽ "văng" lỗi đỏ lòm ngay
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}



# QUY TRÌNH: KHỞI TẠO DANH SÁCH ĐEN VÀ THỰC THI CHẶN IP
# Định nghĩa Object (Không cần dấu nháy lằng nhằng)
$payload = @{
    name    = "SOAR_Blacklist"
    type    = "host"
    address = @("192.168.150.100")
    descr   = "Danh_sach_IP_bi_SOAR_chan"
} | ConvertTo-Json

# Gửi request
Invoke-RestMethod -Uri "https://192.168.2.1/api/v2/firewall/alias" `
                  -Method Post `
                  -Headers @{"x-api-key"="YOUR_PFSENSE_API_KEY"} `
                  -ContentType "application/json" `
                  -Body $payload

# Sau khi nhồi IP xong, chạy tiếp dòng này:
curl.exe -k -X POST "https://192.168.2.1/api/v2/firewall/apply" `
         -H "x-api-key: YOUR_PFSENSE_API_KEY" `
         -H "Content-Type: application/json"



# QUY TRÌNH CẬP NHẬT & THỰC THI CHẶN IP (UPDATE & APPLY FLOW)
# Biến cấu hình
$idAlias = 5  # <--- KIỂM TRA LẠI ID TRÊN WEBGUI XEM ĐÚNG LÀ SỐ 0 KHÔNG NHÉ
$ipToBlock = "192.168.150.200"
$apiKey = "YOUR_PFSENSE_API_KEY" 
$pfsenseIp = "192.168.2.1"

# 1. TẠO PAYLOAD CÓ CHỨA ID (DẠNG JSON CHUẨN)
$payload = @{
     id      = $idAlias
     name    = "SOAR_Blacklist"
     address = @($ipToBlock)
} | ConvertTo-Json

write-host "--- Đang PATCH Alias ID $idAlias với IP $ipToBlock ---" -ForegroundColor Cyan

# 2. GỬI LỆNH PATCH (DÙNG TRY-CATCH ĐỂ BẮT LỖI)
try {
    Invoke-RestMethod -Uri "https://$($pfsenseIp)/api/v2/firewall/alias" `
                      -Method Patch `
                      -Headers @{"x-api-key"=$apiKey} `
                      -ContentType "application/json" `
                      -Body $payload
    write-host "--- PATCH thành công! ---" -ForegroundColor Green
} catch {
    write-host "--- PATCH thất bại: $_ ---" -ForegroundColor Red
}

# 3. APPLY ĐỂ CÓ HIỆU LỰC
curl.exe -k -X POST "https://$($pfsenseIp)/api/v2/firewall/apply" `
         -H "x-api-key: $($apiKey)"

write-host "--- Đã gửi lệnh Apply. Check WebGUI ngay nhé! ---" -ForegroundColor Yellow

Sau khi xong bước này vào Pfsense NGFW để đặt rules WAN và LAN cho sanh sách SOAR BlackList mới thêm vào


WAN

- Action: Block (hoặc Reject).
- Protocol: Any (Để nó không "ăn" mã được bằng bất cứ đường nào).
- Source: SOAR_Blacklist (Cái Alias ông vừa tạo).
-vDestination: Any (Hoặc WAN Address).
Ý nghĩa: "Bất kể thằng nào nằm trong danh sách đen (Source) mà dám gửi gói tin tới nhà tui (Destination) là tui vả rụng nụ ngay!".

LAN

- Action: Block.
- Protocol: Any.
- Source: LAN net or Any (Toàn bộ máy trong mạng nội bộ của ông).
- Destination: SOAR_Blacklist.
Ý nghĩa: "Cấm tuyệt đối mấy máy trong nhà (Source) liên lạc với mấy cái IP xấu trong danh sách đen (Destination)".



# QUY TRÌNH CẬP NHẬT ĐỐI TƯỢNG QUA ID (ID-BASED UPDATE FLOW)
# Biến cấu hình
$idAlias = 5  # <--- ĐÂY LÀ CHÌA KHÓA! ID ông lấy từ kết quả POST lúc nãy
# Cái ID (idAlias = 5) này không cố định. Sau khi ông chạy lệnh POST tạo Alias lần đầu, pfSense sẽ trả về một ID. Ông phải lấy đúng cái ID đó điền vào thì lệnh PATCH mới "ăn" mã được.
$ipToBlock = "192.168.150.200"
$apiKey = "YOUR_PFSENSE_API_KEY"
$pfsenseIp = "192.168.2.1"

# 1. Tạo file JSON tạm (Thêm trường "id" vào nhé)
$jsonContent = '{"id": ' + $idAlias + ', "name": "SOAR_Blacklist", "address": ["' + $ipToBlock + '"]}'
$jsonContent | Out-File -FilePath "payload.json" -Encoding ascii

Write-Host "--- Đang PATCH (Update) Alias ID $idAlias với IP: $ipToBlock ---" -ForegroundColor Cyan

# 2. Gọi curl (Dùng file @payload.json cho nó "khét")
curl.exe -k -X PATCH "https://$($pfsenseIp)/api/v2/firewall/alias" `
         -H "x-api-key: $($apiKey)" `
         -H "Content-Type: application/json" `
         -d "@payload.json"

Write-Host "--- Đang kích hoạt (Apply) ---" -ForegroundColor Yellow

# 3. Kích hoạt (Apply)
curl.exe -k -X POST "https://$($pfsenseIp)/api/v2/firewall/apply" `
         -H "x-api-key: $($apiKey)" `
         -H "Content-Type: application/json"

# 4. Dọn dẹp
if (Test-Path "payload.json") { Remove-Item "payload.json" }

Write-Host "--- XONG! Check lại WebGUI xem IP mới đã vào chưa nhé! ---" -ForegroundColor Green



# QUY TRÌNH KIỂM TRA & TỔNG HỢP DANH SÁCH (INVENTORY CHECK FLOW)
curl.exe -k -X GET "https://192.168.2.1/api/v2/firewall/aliases" `
         -H "x-api-key: YOUR_PFSENSE_API_KEY"