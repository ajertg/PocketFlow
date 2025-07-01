@echo off
echo.
echo ==========================================
echo  Starting IC Replica for PocketFlow
echo ==========================================
echo.

REM Check if container is running
docker-compose ps | findstr "dfx" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo [INFO] Starting development container...
    docker-compose up -d
    echo [INFO] Waiting for container to be ready...
    timeout /t 5 /nobreak >nul
)

echo [INFO] Setting up DFX environment...
docker-compose exec dfx /workspace/scripts/setup-container.sh

echo.
echo [INFO] Checking if IC replica is already running...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx ping local" >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] IC replica is already running!
    goto :show_status
)

echo [INFO] Starting IC replica (this may take a moment)...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx start --clean --background"

echo [INFO] Waiting for IC replica to be ready...
docker-compose exec dfx bash -c "sleep 15"

echo [INFO] Verifying replica status...
set /a attempts=0
:check_replica
set /a attempts+=1
if %attempts% gtr 12 (
    echo [WARNING] Replica taking longer than expected, but continuing...
    goto :show_status
)

echo [INFO] Checking replica... attempt %attempts%/12
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx ping local" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Replica still starting... waiting a bit more...
    docker-compose exec dfx bash -c "sleep 5"
    goto :check_replica
)

:show_status
echo.
echo [SUCCESS] IC replica is running!
echo.
echo ==========================================
echo  Replica Status
echo ==========================================
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx ping local"

echo.
echo ==========================================
echo  Ready for Deployment!
echo ==========================================
echo.
echo You can now run:
echo   scripts\deploy-pocketflow.bat  - Deploy PocketFlow canisters
echo   scripts\test-integration.bat   - Run integration tests
echo   scripts\simple-test.bat        - Quick deployment test
echo.
pause