EA - Security Lab VPN Setup

Đầu tiên để thông nòng đường hầm cho việc truy cập từ xa

1. Cài các Package Manager cần thiết và Cài App và Doamin ở máy local host

Ở pfsense vào Package Manager cài 

Tailscale
WireGuard

Ở local host vào 2 trang web này để cài về máy

WireGuard=https://www.wireguard.com/install/
Tailscale=https://tailscale.com/download

Sau khi cài xong tụi này ở pfsense, vào mục VPN tụi này sẽ xuất hiện ở đó

Muốn Free thì vào DuckDNS để tạo 1 domain vì đây là domain của pfsense luôn

DuckDNS=https://www.duckdns.org/domains

vào trang rồi sao đó là tạo 1 cái domain riêng cho mình

Còn Bạn có domain riêng thì không cần cài them và Dynamic DNS ở bước sau sẽ khá kén chọn DNS có thể có hoặc không có

2. Cấu hình cho WireGuard

Vì khúc này sẽ hơi rối nên cứ làm theo trình tự

2.1 Vào WireGuard ở VPN pfsense tạo cái Tunnels

- Enable: Enable Tunnel
- Listen Port: 51820
- Tạo cái Interface Keys: "Key quan trọng để xác định danh tính của Pfsense gọi tắt là Key AAA"

Sau đó Save

2.2 Vào Peers kế bên Tunnels

- Enable: Enable Peer
- Dynamic Endpoint: Dynamic

Bước này cần phải tải WireGuard ở bước trên để lấy Key

Vào app WireGuard trên local host đã cài, bấm Add Tunnel ở dòng dưới

- Name: "Đặt gì cũng đc"
- Public key: "Chuỗi quan trọng trên App gọi tắt là Key BBB"

Rồi dán này ở cột bên dưới

[Interface]
PrivateKey = "Dán chuỗi Key BBB vào"
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = "Dán chuỗi Key AAA vào"
AllowedIPs = 10.0.0.0/24, 192.168.2.0/24
Endpoint = "Domain của bạn":51820

Vào lại pfsense dán cái chuỗi Key BBB đó vào Peers tiếp nối mới giai đoạn trên

- Public Key: " Chuỗi Key BBB"

Tiếp đến là Address Configuration ở Peers

- Allowed IPs: 10.0.0.2/32 Tùy người đặt vì đây là Ip của Tunnel

# Lưu ý: Cái WireGuard ở App trên local luôn luôn bật không tắt

Sau đó vào mục Interfaces rồi bật cái tun_wg0 lúc tạo cái Peers trong Pfsense

- Enable: Enable Interface
- IPv4: Static IPv4

- IPv4 Address: 10.0.0.1/24

Rồi Save

3. Cấu hình Dynamic DNS # Đây là bước thêm domain vào và khá kén chọn DNS

Vào mục Services có chỗ là Dynamic DNS bấm vào

Khi bấm vào Dynamic DNS rồi bấm Add ở Dynamic DNS Clients

- Service Type: Custom
- Interface to monitor: WAN
- Interface to send update from: WAN
- Check IP Mode: Always use the check IP service
- Username: Tên domain
- Password: Token của domain
- Update URL: https://www.duckdns.org/update?domains=%HOST%&token=%PASS%&ip=%IP
"Ví dụ: https://www.duckdns.org/update?domains=ea-soar&token=<YOUR_DUCKDNS_TOKEN>&ip=%IP%"
- Result Match: OK

Sau đó Save & Force Update

4. Cấu hình Tailscale

Đầu tiên là vào link Tailscale tải ở bước trước tải về

Tải rồi đăng nhập tài khoản như thường lệ

Sau khi cài xong vào lại link Tailscale rồi kiếm dòng Admin console rồi bấm vào

Sau khi bấm vào tìm kếm Settings vào Keys có chỗ là Auth keys bấm tạo Generate auth key...

Sao chép cái key đó và quay lại pfsense vào VPN Tailscale vào tab Authentication

- Pre-authentication Key: Chép cái chuỗi lúc nãy tạo vào

Rồi Save

Qua tab Settings

- Enable: Enable Tailscale
- Keep Configuration: Enbale
- Accecp DNS: Accept DNS configuration from the control server
- Advertised Routes: 192.168.40.0/24 # Đây là dãy IP của VLANS SERVER tùy vào những thứ bạn muốn để là gì hoặc ip của VLANS SERVER của bạn

Rồi Save

5. Đặt Rules

5.1 Vào Rules tab WireGuard do đây chúng ta thấy có 1 interfaces của WireGuard sẽ lú vì ở bước trước có kêu bật interfaces thì đó là interfaces riêng còn cái hiện có sẵn là group nên là đặt rules y chang cho cả 2 đứa by chang luôn

Rules 1

- Action: Pass
- Address Family: IPv4
- Protocol: TCP
- Source: WIRE nets
- Destination: LAN address
- Destination Port Range: 443

Rules 2

- Action: Pass
- Address Family: IPv4
- Protocol: TCP/UDP
- Source: WIRE nets
- Destination: SERVERS nets
- Destination Port Range: Any

Rules 3

- Action: Pass
- Address Family: IPv4
- Protocol: Any
- Source: WIRE nets
- Destination: Any
- Destination Port Range: Any

5.2 Vào Rules tab Tailscale của Group lẫn Riêng

- Action: Pass
- Address Family: IPv4
- Protocol: Any
- Source: Any
- Destination: LAN address
- Destination Port Range: Any

Bonus nếu muốn Tải Wazuh ở VLANS SERVER

Tạo 1 máy VM hoặc Wazuh về máy

curl -sO https://packages.wazuh.com/4.10/wazuh-install.sh && sudo bash wazuh-install.sh -a

Wazuh
User: admin
Password: <YOUR_WAZUH_ADMIN_PASSWORD>