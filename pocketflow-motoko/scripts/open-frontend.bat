@echo off
echo.
echo ==========================================
echo  PocketFlow Frontend (Manual Setup)
echo ==========================================
echo.

REM Check if frontend files exist
set FRONTEND_PATH=%cd%\examples\hello-world\frontend\index.html

if not exist "%FRONTEND_PATH%" (
    echo [ERROR] Frontend files not found at: %FRONTEND_PATH%
    echo Make sure you're in the pocketflow-motoko directory
    pause
    exit /b 1
)

echo [INFO] Opening PocketFlow frontend...
echo.
echo Frontend location: %FRONTEND_PATH%
echo.

REM Open the frontend in the default browser
start "" "%FRONTEND_PATH%"

echo [SUCCESS] Frontend opened in your browser!
echo.
echo ==========================================
echo  Manual Setup Instructions:
echo ==========================================
echo.
echo 1. Get your canister ID:
echo    - Run: scripts\simple-test.bat
echo    - Look for the canister ID in the output
echo    - OR run: docker-compose exec dfx bash
echo    - Then: export PATH=/root/bin:$PATH
echo    - Then: dfx canister id hello_world_example
echo.
echo 2. In the frontend:
echo    - Paste the canister ID in the "Canister ID" field
echo    - Click "Test Example" to test the workflow
echo    - Or enter your own question and click "Run Workflow"
echo.
echo 3. Troubleshooting:
echo    - Make sure IC replica is running (scripts\simple-test.bat)
echo    - Check that your canister is deployed
echo    - Verify the canister ID is correct
echo.
pause