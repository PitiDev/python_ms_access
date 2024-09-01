@echo off
setlocal enabledelayedexpansion

REM Check if Python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python could not be found. Please install it first.
    echo Visit https://www.python.org/downloads/ for installation instructions.
    exit /b 1
)

REM Check Python version
for /f "tokens=2 delims=." %%i in ('python --version 2^>^&1') do set python_version=%%i
if %python_version% lss 6 (
    echo Python version 3.6 or higher is required.
    exit /b 1
)

REM Check if pip is installed
python -m pip --version >nul 2>nul
if %errorlevel% neq 0 (
    echo pip is not installed. Installing pip...
    python -m ensurepip --default-pip
)

REM Upgrade pip
python -m pip install --upgrade pip

REM Check if venv module is available
python -c "import venv" >nul 2>nul
if %errorlevel% neq 0 (
    echo venv module not found. Please ensure you're using Python 3.3 or newer.
    exit /b 1
)

REM Check if ngrok is installed
where ngrok >nul 2>nul
if %errorlevel% neq 0 (
    echo ngrok could not be found. Please install it first.
    echo Visit https://ngrok.com/download for installation instructions.
    exit /b 1
)

REM Create and activate virtual environment
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip in the virtual environment
python -m pip install --upgrade pip

REM Install requirements
echo Installing requirements...
pip install -r requirements.txt

REM Check if mdbtools is needed and available
python -c "import subprocess; subprocess.run(['mdb-tables', '--version'], check=True)" >nul 2>nul
if %errorlevel% neq 0 (
    echo WARNING: mdbtools is not installed or not in PATH.
    echo If you need to work with .mdb files, please install mdbtools manually.
    echo You can download it from: https://github.com/mdbtools/mdbtools/releases
    pause
)

REM Run the Flask app
echo Starting Flask API...
start /B python app.py

REM Wait for the Flask app to start
echo Waiting for Flask app to start...
timeout /t 5 /nobreak >nul

REM Start ngrok with custom domain
echo Starting ngrok with custom domain...
ngrok http --domain=walrus-vital-adversely.ngrok-free.app 9000

REM Cleanup: stop the Flask app when ngrok is closed
taskkill /F /IM python.exe >nul 2>nul

echo Flask API and ngrok have been stopped.
pause