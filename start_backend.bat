@echo off
cd /d "%~dp0backend"
echo Starting AscendIA backend...
uvicorn main:app --reload --host 0.0.0.0 --port 8000
