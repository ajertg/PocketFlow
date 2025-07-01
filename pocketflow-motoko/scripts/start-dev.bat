@echo off
echo.
echo =========================================
echo  PocketFlow Motoko - Windows Dev Setup
echo =========================================
echo.

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running or not installed
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo [INFO] Docker is running
echo [INFO] Starting PocketFlow development environment...
echo.

REM Start Docker Compose
docker-compose up -d

if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Docker environment
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Development environment started!
echo.
echo Next steps:
echo   1. Run: docker-compose exec dfx bash
echo   2. Inside container: ./scripts/quick-test.sh
echo.
echo Or run: scripts\test-in-container.bat
echo.
pause