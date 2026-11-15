#!/bin/bash
set -e

echo "========================================================"
echo "Ollama qwen2.5:3b Modeli Indiriliyor ve Kuruluyor..."
echo "========================================================"

docker exec -it ollama ollama pull qwen2.5:3b

echo ""
echo "Model basariyla indirildi! Test ediliyor..."
docker exec -it ollama ollama list
