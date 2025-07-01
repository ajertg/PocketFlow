@echo off
echo.
echo ====================================
echo  PocketFlow Container Debug Info
echo ====================================
echo.

REM Check if container is running
docker-compose ps | findstr "dfx" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Development container is not running
    echo Please run scripts\start-dev.bat first
    pause
    exit /b 1
)

echo [INFO] Gathering debug information...
echo.

REM Run debug script in container
docker-compose exec dfx /workspace/scripts/debug-container.sh

echo.
echo [INFO] Debug information collected
echo.
echo Next steps:
echo   - If DFX not installed: Run scripts\simple-test.bat (installs automatically)
echo   - If ports not working: Use direct canister calls instead of web interface
echo   - To enter container: docker-compose exec dfx bash
echo.
pause