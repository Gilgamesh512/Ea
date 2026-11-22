# EA — Ollama AI Local Decision Engine

Thành phần AI hỗ trợ phân tích an ninh cục bộ của nền tảng **EA**. Sử dụng các mô hình ngôn ngữ lớn (Local LLM) để phân tích log thô, tóm tắt hành vi tấn công và hỗ trợ n8n ra quyết định điều phối an toàn mà không để lộ dữ liệu mật ra Internet.

---

## 1. Khởi chạy nhanh

Đứng tại thư mục này và khởi chạy:

```bash
docker compose up -d
```

- **API Endpoint:** `http://localhost:11434`
- **Dữ liệu model lưu trữ tại:** `./ollama_data/`
- **Tăng tốc phần cứng:** Hỗ trợ NVIDIA Container Toolkit (GPU Passthrough). Nếu máy chạy CPU, có thể bỏ phần `deploy.resources.reservations` trong `docker-compose.yml`.

---

## 2. Tải và Quản lý Mô hình AI

### Tải các mô hình chuẩn cho SOC:
```bash
# Mô hình suy luận và phân tích chuỗi tấn công (Khuyên dùng):
docker exec -it ea-ollama ollama pull deepseek-r1:8b

# Mô hình phân tích mã độc / cấu hình an ninh:
docker exec -it ea-ollama ollama pull qwen2.5-coder:7b
```

### Kiểm tra danh sách mô hình đã tải:
```bash
docker exec -it ea-ollama ollama list
```

### Chạy thử nghiệm trực tiếp qua CLI:
```bash
docker exec -it ea-ollama ollama run deepseek-r1:8b
```

---

## 3. Tích hợp với EA SOAR (n8n)

Workflow n8n gọi Ollama qua HTTP POST API:
- **URL:** `http://host.docker.internal:11434/api/generate`
- **Method:** `POST`
- **Payload:**
```json
{
  "model": "deepseek-r1:8b",
  "prompt": "Phân tích mối đe dọa từ log sau: ...",
  "stream": false
}
```
Mô hình sẽ trả về kết quả tóm tắt trong trường `response` của JSON trả về.
