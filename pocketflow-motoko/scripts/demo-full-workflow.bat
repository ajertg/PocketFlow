@echo off
echo.
echo ==========================================
echo  PocketFlow Motoko - Complete Demo
echo ==========================================
echo.
echo This demo shows PocketFlow running on the Internet Computer
echo with the same workflow pattern as cookbook/pocketflow-hello-world
echo.
pause

echo.
echo [STEP 1] Deploying PocketFlow to Internet Computer...
call scripts\deploy-pocketflow.bat

echo.
echo [STEP 2] Running Integration Tests...
echo.
echo Testing Python cookbook compatibility:
echo   Python: qa_flow.run(shared) 
echo   Motoko: hello_world_example.run_workflow(question)
echo.
pause
call scripts\test-integration.bat

echo.
echo [STEP 3] Demonstrating Web Interface...
echo.
echo Opening beautiful frontend that connects to your IC canisters
echo.
pause
call scripts\open-frontend.bat

echo.
echo ==========================================
echo  🎉 PocketFlow Demo Complete!
echo ==========================================
echo.
echo What you just experienced:
echo.
echo ✅ PocketFlow workflow engine running on Internet Computer
echo ✅ Python cookbook compatibility maintained  
echo ✅ Mock LLM service for AI integration
echo ✅ Beautiful web interface for interaction
echo ✅ Complete prep→exec→post node pattern
echo ✅ Local deployment with PocketIC
echo.
echo Python Cookbook Alignment:
echo   cookbook/pocketflow-hello-world/main.py     ←→ hello_world_example.test()
echo   cookbook/pocketflow-hello-world/flow.py     ←→ AnswerNode class
echo   cookbook/pocketflow-hello-world/utils/...   ←→ llm_mock_service
echo.
echo Architecture:
echo   Python PocketFlow ←→ Motoko PocketFlow
echo   Local execution   ←→ Internet Computer
echo   OpenAI API        ←→ Mock LLM Service
echo   Dict shared state ←→ Function parameters
echo.
echo Your PocketFlow is now ready for:
echo   🤖 Real LLM integration (OpenAI, Anthropic, etc.)
echo   🔗 Complex multi-node workflows
echo   🌐 Production deployment to IC mainnet
echo   📊 Advanced data processing pipelines
echo   🔄 Cross-chain workflow orchestration
echo.
echo Documentation: README_DEPLOYMENT.md
echo Support: Check the scripts/ directory for utilities
echo.
pause