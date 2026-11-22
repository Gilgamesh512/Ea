Đầu tiên ở Pfsense NGFW tải REST API, khi tải xong thiết lập các thứ cần thiết:

Vào System -> Advanced -> Admin Access tích vào những ô sau:
Max Processes chỉnh thành 8
WebGUI Login Autocomplete
Roaming
DNS Rebind Check
Browser HTTP_REFERER enforcement

Vào System -> Advanced -> Networking và TÍCH CHỌN (Disable)
Hardware Checksum Offloading
Hardware TCP Segmentation Offloading
Hardware Large Receive Offloading

Nếu có sử dụng Suricata hay Snort thì vào Suricata tạo 1 Interface WAN sau đó truy cập vào WAN đã tạo tích các mục này:
Enable HTTP Log
Append HTTP Log
Log Extended HTTP Info
EVE JSON Log (Quan trọng nhất)

Vào REST API
Allowed Interfaces (Cho phép các Interfaces cần thiết) LAN hay là phòng SERVER
Authentication Methods Chọn cả Local database và Key

Cuối cùng là tự them API Key riêng



Cách sử dụng n8n
Vào n8n localhost:5678
Vào mục Credential chọn Authentication: Header Auth. Name: x-api-key (Phải là chuẩn như đã bàn tùy vào REST API mà tên khác nhau). Value: (Sử dụng API Key đã tạo).
Sau khi Credential xong vào Workflow thì sẽ thấy dấu (+) có dòng Add First Step... Sẽ thấy các dòng thì Lựa chọn hàng đầu: Trigger manually sau đó là On webhook call và On app event



Đến đây là bước quan trong để Khởi tạo GET Method

Method chọn GET
URL https://"IpPfsense"/api/v2/firewall/aliases
Authentication chọn Generic Credential Type rồi chọn Header Auth như bước thêm Credential
Tích chọn Send Headers để chuẩn Header và TẤT CẢ các node (GET, POST, PATCH, APPLY) đều phải có 2 cái Header Accept và Content-Type là application/json

Header 1:
Name: Accept
Value: application/json
Header 2:
Name: Content-Type
Value: application/json

Tích vào Add option để kiếm thêm Ignore SSL Issues (Insecure) và Response sau đó là tích hết 2 thằng này để sáng đèn 

Execute step thế là xong bước GET
Bước này để kiểm tra danh sách và id kèm theo



Khởi tạo để POST

Thay vì tạo 1 node mới bạn chỉ cần copy cái node ở bước GET Method là được

Method chọn POST
URL https://192.168.2.1/api/v2/firewall/alias
Tích chọn Send Headers
Send Body, Body Content Type chọn JSON, Specify Body chọn Using JSON rồi copy đoạn sau:
{
  "name": "SOAR_Whitelist",
  "type": "host",
  "address": ["192.168.2.10"], 
  "descr": "Danh_sach_IP_tin_cay_cua_EA"
}

Execute step thế là xong bước POST
Bước này để tạo 1 danh sách và ip mới



Khởi tạo để PATCH

Method chọn PATCH
URL https://192.168.2.1/api/v2/firewall/alias
Tích chọn Send Headers
Send Body, Body Content Type chọn JSON, Specify Body chọn Using JSON rồi copy đoạn sau:
{
  "id": 6, 
  "address": ["192.168.2.50"]
}

Execute step thế là xong bước PATCH
Bước này để chèn 1 ip mới vào danh sách có sẵn và id chỉ cần đổi id và ip cần nhồi là được



Khởi tạo APPLY
Method chọn POST
URL https://192.168.2.1/api/v2/firewall/apply
Tích chọn Send Headers, Ignore SSL Issues (Insecure), Send Body y chang các bước trên
trong Using JSON {} để tránh báo lỗi và chỉ cần chạy 01 LẦN DUY NHẤT