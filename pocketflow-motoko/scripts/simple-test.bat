@echo off
echo.
echo =============================================
echo  PocketFlow Simple Test (No Web Interface)
echo =============================================
echo.

REM Check if container is running
docker-compose ps | findstr "dfx" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Development container is not running
    echo Please run scripts\start-dev.bat first
    pause
    exit /b 1
)

echo [INFO] Running simple core functionality test...
echo [INFO] This test focuses on canister deployment and direct calls
echo [INFO] No web interface required
echo.

REM Setup environment if needed
echo [INFO] Setting up environment (if needed)...
docker-compose exec dfx /workspace/scripts/setup-container.sh

echo.
echo [INFO] Running core PocketFlow tests...
echo.

REM Run simple tests
docker-compose exec dfx /workspace/scripts/simple-test.sh

echo.
echo [INFO] Simple test completed!
echo.
echo To debug issues:
echo   - Run: scripts\debug-container.bat
echo   - Check: docker-compose logs dfx
echo.
echo To interact manually:
echo   - Run: docker-compose exec dfx bash
echo   - Then: dfx canister call hello_world_example test
echo.
pause