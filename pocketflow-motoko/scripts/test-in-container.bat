@echo off
echo.
echo ==========================================
echo  Running PocketFlow Tests in Container
echo ==========================================
echo.

REM Check if container is running
docker-compose ps | findstr "dfx" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Development container is not running
    echo Please run scripts\start-dev.bat first
    pause
    exit /b 1
)

echo [INFO] Entering container and setting up environment...
echo.

REM First setup the container (this will install DFX)
echo [INFO] Setting up DFINITY environment in container...
docker-compose exec dfx /workspace/scripts/setup-container.sh

if %errorlevel% neq 0 (
    echo [ERROR] Failed to setup environment
    pause
    exit /b 1
)

echo.
echo [INFO] Running PocketFlow tests...
echo.

REM Run tests in container
docker-compose exec dfx /workspace/scripts/quick-test.sh

echo.
echo [INFO] Tests completed!
echo.
echo You can now access:
echo   - Candid UI: http://localhost:8000/_/candid
echo   - Test individual functions in the web interface
echo.
pause