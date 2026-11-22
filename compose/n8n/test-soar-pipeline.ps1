# ==============================================================================
# EA SOAR PIPELINE SIMULATOR - KIỂM THỬ LUỒNG DỮ LIỆU SOAR KHÔNG CẦN CÀI WAZUH
# ==============================================================================

param(
    [string]$WebhookUrl = "http://localhost:5678/webhook/wazuh-alert"
)

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "   EA SOAR AUTOMATED PIPELINE TEST SUITE" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Target Webhook: $WebhookUrl`n"

# ------------------------------------------------------------------------------
# TEST CASE 1: KẺ TẤN CÔNG NGOẠI VI (EXPECTED: CHẶN THÀNH CÔNG)
# ------------------------------------------------------------------------------
Write-Host "[TEST CASE 1] Giả lập kẻ tấn công từ Internet (IP: 203.0.113.195)..." -ForegroundColor Yellow

$payloadHacker = @{
    timestamp = (Get-Date).ToString("o")
    rule = @{
        id = "5710"
        level = 10
        description = "SSH Brute Force attack detected from external IP"
    }
    data = @{
        src_ip = "203.0.113.195"
        dst_port = 22
        protocol = "TCP"
    }
} | ConvertTo-Json

try {
    $res1 = Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType "application/json" -Body $payloadHacker
    Write-Host " -> Đã gửi Payload Test Case 1 thành công!" -ForegroundColor Green
    Write-Host " -> Kỳ vọng: n8n gọi Ollama AI -> Tìm ID Alias -> Thêm 203.0.113.195 vào SOAR_Blacklist trên pfSense.`n" -ForegroundColor Gray
} catch {
    Write-Host " -> Lỗi gửi Test Case 1: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# ------------------------------------------------------------------------------
# TEST CASE 2: CẢNH BÁO LIÊN QUAN ĐẾN 'NGƯỜI NHÀ' (EXPECTED: KÍCH HOẠT ANTI-LOCKOUT, KHÔNG ĐƯỢC CHẶN)
# ------------------------------------------------------------------------------
Write-Host "[TEST CASE 2] Giả lập cảnh báo phát sinh từ Gateway nội bộ (IP: 192.168.2.1)..." -ForegroundColor Yellow

$payloadGateway = @{
    timestamp = (Get-Date).ToString("o")
    rule = @{
        id = "1002"
        level = 12
        description = "High rate of connection requests from Core Gateway / Internal asset"
    }
    data = @{
        src_ip = "192.168.2.1"
        dst_port = 443
        protocol = "TCP"
    }
} | ConvertTo-Json

try {
    $res2 = Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType "application/json" -Body $payloadGateway
    Write-Host " -> Đã gửi Payload Test Case 2 thành công!" -ForegroundColor Green
    Write-Host " -> Kỳ vọng: Bộ lọc Safe Safeguard kích hoạt -> TỪ CHỐI CHẶN -> Bảo toàn hệ thống mạng an toàn.`n" -ForegroundColor Gray
} catch {
    Write-Host " -> Lỗi gửi Test Case 2: $_" -ForegroundColor Red
}

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Kiểm tra tab 'Executions' trên WebUI n8n (http://localhost:5678) để xem chi tiết luồng chạy!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
