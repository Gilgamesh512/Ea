#!/usr/bin/env bash
# ==============================================================================
# EA SOAR PIPELINE SIMULATOR - KIỂM THỬ LUỒNG DỮ LIỆU BẰNG CURL
# ==============================================================================

WEBHOOK_URL="${1:-http://localhost:5678/webhook/wazuh-alert}"

echo "======================================================"
echo "   EA SOAR AUTOMATED PIPELINE TEST SUITE (CURL)"
echo "======================================================"
echo "Target Webhook: $WEBHOOK_URL"
echo ""

# TEST CASE 1: KẺ TẤN CÔNG NGOẠI VI
echo "[TEST CASE 1] Giả lập IP tấn công ngoài Internet (203.0.113.195)..."
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
    "rule": {
      "id": "5710",
      "level": 10,
      "description": "SSH Brute Force attack detected from external IP"
    },
    "data": {
      "src_ip": "203.0.113.195",
      "dst_port": 22,
      "protocol": "TCP"
    }
  }'
echo " -> Đã gửi Test Case 1 (Kỳ vọng: Ollama phân tích -> Chặn pfSense)"
echo ""

sleep 2

# TEST CASE 2: NGƯỜI NHÀ / GATEWAY NỘI BỘ
echo "[TEST CASE 2] Giả lập IP Gateway nội bộ (192.168.2.1)..."
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
    "rule": {
      "id": "1002",
      "level": 12,
      "description": "High rate of connection requests from Core Gateway"
    },
    "data": {
      "src_ip": "192.168.2.1",
      "dst_port": 443,
      "protocol": "TCP"
    }
  }'
echo " -> Đã gửi Test Case 2 (Kỳ vọng: Kích hoạt Anti-Lockout -> KHÔNG CHẶN)"
echo ""

echo "======================================================"
echo "Truy cập n8n WebUI (http://localhost:5678) -> Executions để xem kết quả!"
echo "======================================================"
