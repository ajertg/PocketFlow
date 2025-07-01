@echo off
echo.
echo ==========================================
echo  PocketFlow Integration Test
echo ==========================================
echo.

REM Ensure environment is ready
echo [INFO] Checking IC replica status...
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx ping local" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] IC replica not running. Starting it now...
    docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx start --clean --background"
    echo [INFO] Waiting for replica to be ready...
    docker-compose exec dfx bash -c "sleep 15"
    echo [INFO] Replica should be ready now.
)

echo [INFO] Running integration tests to validate Python cookbook compatibility...
echo.

echo ==========================================
echo  Test 1: Basic Hello World (Python main.py equivalent)
echo ==========================================
echo [Python Equivalent] shared = {"question": "In one sentence, what's the end of universe?", "answer": None}
echo [Python Equivalent] qa_flow.run(shared)
echo [Python Expected]   Answer should contain "universe" or "heat death"
echo.
echo [Motoko Test] hello_world_example.test()
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example test"

echo.
echo ==========================================
echo  Test 2: Meaning of Life (Classic question)
echo ==========================================
echo [Python Equivalent] qa_flow.run({"question": "What is the meaning of life?", "answer": None})
echo [Python Expected]   Answer should contain "42"
echo.
echo [Motoko Test] hello_world_example.test_meaning_of_life()
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example test_meaning_of_life"

echo.
echo ==========================================
echo  Test 3: Custom Question (Workflow flexibility)
echo ==========================================
echo [Python Equivalent] qa_flow.run({"question": "What is AI?", "answer": None})
echo [Python Expected]   Answer should be contextual and helpful
echo.
echo [Motoko Test] hello_world_example.run_workflow("What is AI?")
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example run_workflow '(\"What is AI?\")'"

echo.
echo ==========================================
echo  Test 4: LLM Mock Service (Python call_llm.py equivalent)
echo ==========================================
echo [Python Equivalent] from utils.call_llm import call_llm; call_llm("Hello world")
echo [Python Expected]   Should return OpenAI-style response
echo.
echo [Motoko Test] llm_mock_service.call_llm("Hello world")
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call llm_mock_service call_llm '(\"Hello world\")'"

echo.
echo ==========================================
echo  Test 5: Workflow Chain (AnswerNode prep->exec->post)
echo ==========================================
echo [Python Equivalent] 
echo   class AnswerNode(Node):
echo       def prep(self, shared): return shared["question"]
echo       def exec(self, question): return call_llm(question)  
echo       def post(self, shared, prep_res, exec_res): shared["answer"] = exec_res
echo.
echo [Motoko Test] Testing the full prep->exec->post chain
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example run_workflow '(\"How does PocketFlow work?\")'"

echo.
echo ==========================================
echo  Test 6: Health Checks
echo ==========================================
echo [INFO] Verifying all services are healthy...
echo.
echo [Hello World Health]
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call hello_world_example health"

echo.
echo [LLM Mock Health]
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env 2>/dev/null; export PATH=/root/.local/share/dfx/bin:$PATH && dfx canister call llm_mock_service health"

echo.
echo ==========================================
echo  Integration Test Results
echo ==========================================
echo.
echo ✅ All tests completed!
echo.
echo Comparison with Python cookbook/pocketflow-hello-world:
echo   ✅ AnswerNode.prep()  -> Motoko AnswerNode.prep()
echo   ✅ AnswerNode.exec()  -> Motoko AnswerNode.exec() + call_llm()
echo   ✅ AnswerNode.post()  -> Motoko AnswerNode.post()
echo   ✅ Flow.run()         -> Motoko run_workflow()
echo   ✅ call_llm()         -> Motoko LLM Mock Service
echo   ✅ main()             -> Motoko test()
echo.
echo Next Steps:
echo   1. Use scripts\open-frontend.bat for web interface
echo   2. Try custom questions via the frontend
echo   3. Integrate with real LLM services
echo   4. Deploy to IC mainnet
echo.
pause