@echo off
echo.
echo ==========================================
echo  PocketFlow - Simple Deployment
echo ==========================================
echo.

REM Start container if not running
docker-compose ps | findstr "dfx" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo [INFO] Starting container...
    docker-compose up -d
    echo [INFO] Waiting for container...
    docker-compose exec dfx bash -c "sleep 10"
)

echo [INFO] Setting up environment and starting replica...
docker-compose exec dfx bash -c "
    # Setup DFX
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    
    # Install DFX if needed
    if ! command -v dfx >/dev/null 2>&1; then
        curl -fsSL https://internetcomputer.org/install.sh | sh
        source ~/.local/share/dfx/env
    fi
    
    # Start replica (don't wait if already running)
    dfx start --clean --background 2>/dev/null || echo 'Replica may already be running'
    
    # Wait a bit
    sleep 10
    
    echo 'Environment ready!'
"

echo.
echo [INFO] Deploying canisters...

REM Deploy LLM Mock Service
echo [STEP 1] Deploying LLM Mock Service...
docker-compose exec dfx bash -c "
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    dfx deploy llm_mock_service
"

REM Deploy Hello World Example
echo [STEP 2] Deploying Hello World Example...
docker-compose exec dfx bash -c "
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    dfx deploy hello_world_example
"

echo.
echo [SUCCESS] Deployment completed!
echo.

REM Get canister IDs
echo [INFO] Getting canister IDs...
FOR /F "tokens=*" %%i IN ('docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister id hello_world_example 2>/dev/null"') DO SET HELLO_WORLD_ID=%%i
FOR /F "tokens=*" %%i IN ('docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister id llm_mock_service 2>/dev/null"') DO SET LLM_MOCK_ID=%%i

echo.
echo ==========================================
echo  Deployment Results
echo ==========================================
echo.
echo Deployed Canisters:
echo   Hello World Example: %HELLO_WORLD_ID%
echo   LLM Mock Service:    %LLM_MOCK_ID%
echo.
echo Test Commands:
echo   dfx canister call hello_world_example test
echo   dfx canister call hello_world_example run_workflow '("Your question")'
echo   dfx canister call llm_mock_service call_llm '("Your prompt")'
echo.
echo Next Steps:
echo   scripts\test-simple.bat      - Quick testing
echo   scripts\open-frontend.bat    - Web interface
echo.
pause