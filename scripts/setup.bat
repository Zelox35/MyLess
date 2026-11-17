@echo off
chcp 65001 >nul
echo.
echo =====================================================
echo   MYLESS - Hizli Kurulum (Windows)
echo =====================================================
echo.

echo [1/4] Docker servisleri baslatiliyor...
docker compose up -d
if errorlevel 1 (
    echo HATA: Docker Compose baslamiyor. Docker Desktop acik mi?
    pause
    exit /b 1
)

echo.
echo [2/4] n8n ve Ollama hazir olana kadar bekleniyor ^(30 sn^)...
timeout /t 30 /nobreak >nul

echo.
echo [3/4] Ollama modeli kontrol ediliyor...
docker exec ollama ollama list | findstr "qwen2.5:3b" >nul 2>&1
if errorlevel 1 (
    echo Model bulunamadi, indiriliyor ^(ilk kurulum ~2 GB^)...
    docker exec ollama ollama pull qwen2.5:3b
) else (
    echo Model zaten yuklu, atlaniyor.
)

echo.
echo [4/4] n8n workflow'lari ice aktariliyor...
docker exec n8n n8n import:workflow --input=/workflows/00_error_handler_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/1_chat_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/2_summarize_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/3_generate_quiz_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/4_evaluate_quiz_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/10_flashcards_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/11_extract_image_workflow.json 2>nul
docker exec n8n n8n import:workflow --input=/workflows/12_weekly_report_workflow.json 2>nul

echo.
echo =====================================================
echo   KURULUM TAMAMLANDI!
echo =====================================================
echo.
echo   n8n Arayuzu : http://localhost:5678
echo   Ollama API  : http://localhost:11434
echo.
echo   Sonraki adim - Flutter uygulamasini calistirin:
echo     cd smart_study_assistant
echo     flutter pub get
echo     flutter run
echo.
pause