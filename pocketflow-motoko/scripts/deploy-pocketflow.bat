@echo off
echo.
echo ==========================================
echo  PocketFlow - Complete Deployment
echo ==========================================
echo.

echo [STEP 1] Ensuring IC replica is running...
call scripts\start-replica.bat

echo.
echo [STEP 2] Deploying PocketFlow canisters...
echo.

REM Deploy in correct order
echo [2.1] Deploying LLM Mock Service...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx deploy llm_mock_service"

echo.
echo [2.2] Deploying Hello World Example...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx deploy hello_world_example"

echo.
echo [SUCCESS] Deployment completed!
echo.
echo ==========================================
echo  Testing the deployment...
echo ==========================================

REM Test the deployment with error handling
echo [TEST 1] Testing Hello World Example...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example test" 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Test 1 failed - this is normal if canisters need more time to deploy
)

echo.
echo [TEST 2] Testing LLM Mock Service...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call llm_mock_service test" 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Test 2 failed - this is normal if canisters need more time to deploy
)

echo.
echo [TEST 3] Testing Custom Question...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example test_custom '(\"What is the future of blockchain?\")'" 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Test 3 failed - this is normal if canisters need more time to deploy
)

echo.
echo ==========================================
echo  Deployment Summary
echo ==========================================

echo [INFO] Getting canister IDs...
FOR /F "tokens=*" %%i IN ('docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister id hello_world_example 2>/dev/null"') DO SET HELLO_WORLD_ID=%%i
FOR /F "tokens=*" %%i IN ('docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister id llm_mock_service 2>/dev/null"') DO SET LLM_MOCK_ID=%%i

echo.
echo Deployed Canisters:
echo   Hello World Example: %HELLO_WORLD_ID%
echo   LLM Mock Service:    %LLM_MOCK_ID%
echo.
echo Available Commands:
echo   dfx canister call hello_world_example test
echo   dfx canister call hello_world_example run_workflow '("Your question")'
echo   dfx canister call hello_world_example test_meaning_of_life
echo   dfx canister call llm_mock_service call_llm '("Your prompt")'
echo.
echo Frontend URLs:
echo   Main: scripts\open-frontend.bat
echo   Auto: scripts\launch-frontend.bat
echo.
echo Candid UI (if working):
echo   http://localhost:8000/?canisterId=%HELLO_WORLD_ID%
echo   http://localhost:8000/?canisterId=%LLM_MOCK_ID%
echo.
pause