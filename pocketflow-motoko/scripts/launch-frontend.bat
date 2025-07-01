@echo off
echo.
echo ==========================================
echo  PocketFlow Frontend Launcher
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

echo [INFO] Setting up environment and getting canister ID...
echo.

REM First ensure DFX is installed and environment is ready
echo [INFO] Setting up DFX environment...
docker-compose exec dfx /workspace/scripts/setup-container.sh >nul 2>&1

REM Set PATH and get the canister ID
FOR /F "tokens=*" %%i IN ('docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister id hello_world_example 2>/dev/null"') DO SET CANISTER_ID=%%i

if "%CANISTER_ID%"=="" (
    echo [ERROR] Could not get canister ID
    echo Make sure the canister is deployed first:
    echo   scripts\simple-test.bat
    pause
    exit /b 1
)

REM Clean up the canister ID (remove any extra whitespace)
set CANISTER_ID=%CANISTER_ID: =%

echo [SUCCESS] Found canister ID: %CANISTER_ID%
echo.

REM Create the frontend URL
set FRONTEND_PATH=%cd%\examples\hello-world\frontend\index.html
set FRONTEND_URL=file:///%FRONTEND_PATH:\=/%?canisterId=%CANISTER_ID%

echo [INFO] Frontend details:
echo   Location: %FRONTEND_PATH%
echo   Canister: %CANISTER_ID%
echo   URL: %FRONTEND_URL%
echo.

REM Check if frontend files exist
if not exist "%FRONTEND_PATH%" (
    echo [ERROR] Frontend files not found at: %FRONTEND_PATH%
    pause
    exit /b 1
)

echo [INFO] Opening frontend in your default browser...
echo.

REM Open the frontend in the default browser
start "" "%FRONTEND_URL%"

echo [SUCCESS] Frontend launched!
echo.
echo Instructions:
echo   1. The frontend should open in your browser
echo   2. The canister ID should be auto-filled
echo   3. Click "Test Example" or enter your own question
echo   4. If it doesn't work, manually open: %FRONTEND_PATH%
echo.
echo Troubleshooting:
echo   - Make sure IC replica is running (scripts\simple-test.bat)
echo   - Check browser console (F12) for errors
echo   - Verify canister is deployed and responding
echo.
pause