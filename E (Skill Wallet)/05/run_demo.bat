@echo off
if not exist .venv python -m venv .venv
call .venv\Scripts\activate.bat
pip install -r requirements.txt
powershell -Command "(Get-Content .env.example) -replace 'DEMO_MODE=false','DEMO_MODE=true' | Set-Content .env"
uvicorn app.main:app --reload
