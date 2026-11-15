@echo off
echo ========================================================
echo Ollama API Test Ediliyor (qwen2.5:3b)...
echo ========================================================

curl -X POST http://localhost:11434/api/generate -d "{\"model\": \"qwen2.5:3b\", \"prompt\": \"Merhaba! Kısaca kendini tanıt.\", \"stream\": false}"

echo.
pause
