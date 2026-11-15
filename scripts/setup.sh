#!/bin/bash
set -e

echo ""
echo "====================================================="
echo "  MYLESS - Hızlı Kurulum (Linux / macOS)"
echo "====================================================="
echo ""

echo "[1/4] Docker servisleri başlatılıyor..."
docker compose up -d

echo ""
echo "[2/4] n8n ve Ollama hazır olana kadar bekleniyor (30 sn)..."
sleep 30

echo ""
echo "[3/4] Ollama modeli kontrol ediliyor..."
if docker exec ollama ollama list 2>/dev/null | grep -q "qwen2.5:3b"; then
    echo "Model zaten yüklü, atlanıyor."
else
    echo "Model bulunamadı, indiriliyor (ilk kurulum ~2 GB)..."
    docker exec ollama ollama pull qwen2.5:3b
fi

echo ""
echo "[4/4] n8n workflow'ları içe aktarılıyor..."
for file in workflows/*.json; do
    docker exec n8n n8n import:workflow --input="/workflows/$(basename $file)" 2>/dev/null || true
done

echo ""
echo "====================================================="
echo "  KURULUM TAMAMLANDI!"
echo "====================================================="
echo ""
echo "  n8n Arayüzü : http://localhost:5678"
echo "  Ollama API  : http://localhost:11434"
echo ""
echo "  Sonraki adım - Flutter uygulamasını çalıştırın:"
echo "    cd smart_study_assistant"
echo "    flutter pub get"
echo "    flutter run"
echo ""
