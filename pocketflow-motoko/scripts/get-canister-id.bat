@echo off
echo.
echo ==========================================
echo  Get PocketFlow Canister ID
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

echo [INFO] Setting up environment if needed...
docker-compose exec dfx /workspace/scripts/setup-container.sh

echo.
echo [INFO] Getting canister information...
echo.

echo ==========================================
echo  Canister Information:
echo ==========================================

REM Get canister IDs with proper PATH
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && echo 'Hello World Example:' && dfx canister id hello_world_example 2>/dev/null || echo 'Not deployed yet'"

echo.
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && echo 'PocketFlow Core:' && dfx canister id pocketflow_core 2>/dev/null || echo 'Not deployed yet'"

echo.
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && echo 'Map Reduce Example:' && dfx canister id map_reduce_example 2>/dev/null || echo 'Not deployed yet'"

echo.
echo ==========================================
echo  Instructions:
echo ==========================================
echo.
echo 1. Copy the "Hello World Example" canister ID above
echo 2. Run: scripts\open-frontend.bat
echo 3. Paste the canister ID in the frontend
echo 4. Click "Test Example" to test PocketFlow
echo.
echo If no canister IDs are shown:
echo   - Run: scripts\simple-test.bat
echo   - This will deploy the canisters first
echo   - Then run this script again
echo.
pause