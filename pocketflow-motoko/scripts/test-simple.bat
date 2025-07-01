@echo off
echo.
echo ==========================================
echo  PocketFlow - Simple Testing
echo ==========================================
echo.

echo [INFO] Testing deployed canisters...
echo.

echo [TEST 1] Basic Hello World Test...
docker-compose exec dfx bash -c "
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    echo 'Calling hello_world_example.test()...'
    dfx canister call hello_world_example test 2>/dev/null || echo 'Test failed - canister may not be ready yet'
"

echo.
echo [TEST 2] Custom Question Test...
docker-compose exec dfx bash -c "
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    echo 'Calling hello_world_example.run_workflow(\"What is blockchain?\")...'
    dfx canister call hello_world_example run_workflow '(\"What is blockchain?\")' 2>/dev/null || echo 'Test failed - canister may not be ready yet'
"

echo.
echo [TEST 3] LLM Mock Service Test...
docker-compose exec dfx bash -c "
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    echo 'Calling llm_mock_service.test()...'
    dfx canister call llm_mock_service test 2>/dev/null || echo 'Test failed - canister may not be ready yet'
"

echo.
echo [TEST 4] Health Checks...
docker-compose exec dfx bash -c "
    source ~/.local/share/dfx/env 2>/dev/null || true
    export PATH='/root/.local/share/dfx/bin:$PATH'
    echo 'Checking hello_world_example.health()...'
    dfx canister call hello_world_example health 2>/dev/null || echo 'Health check failed'
    echo 'Checking llm_mock_service.health()...'
    dfx canister call llm_mock_service health 2>/dev/null || echo 'Health check failed'
"

echo.
echo ==========================================
echo  Testing Complete
echo ==========================================
echo.
echo If tests failed, the canisters may need more time to deploy.
echo You can also manually test with:
echo.
echo   docker-compose exec dfx bash
echo   source ~/.local/share/dfx/env
echo   dfx canister call hello_world_example test
echo.
echo To open web interface:
echo   scripts\open-frontend.bat
echo.
pause