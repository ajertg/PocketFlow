# PocketFlow Motoko - Local Deployment & Integration Guide

Complete guide to deploy and test PocketFlow on the Internet Computer with mock LLM integration, aligned with the Python cookbook example.

## 🚀 Quick Start

### **Optimized Workflow (Recommended)**
```bash
# First time: Build cached image (one-time setup)
scripts/build-optimized-container.bat

# Fast deployment (uses cached image - 10-30 seconds vs 6-9 minutes!)
scripts/deploy-pocketflow.bat

# Test Python cookbook compatibility
scripts/test-integration.bat

# Open beautiful web interface
scripts/open-frontend.bat
```

### **Traditional Workflow (Slower)**
```bash
# This will re-download Ubuntu packages every time (~6-9 minutes)
scripts/deploy-pocketflow.bat
scripts/test-integration.bat
scripts/open-frontend.bat
```

## 📋 Architecture Overview

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  Frontend (HTML)    │───▶│  Hello World        │───▶│  LLM Mock Service   │
│  • Web Interface    │    │  Example Canister   │    │  Canister           │
│  • User Input       │    │                     │    │                     │
│  • Results Display  │    │  • AnswerNode       │    │  • call_llm()       │
│                     │    │  • Workflow Logic   │    │  • Mock Responses   │
│                     │    │  • Python Alignment │    │  • Pattern Matching │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

## 🔄 Python Cookbook Alignment

This Motoko implementation mirrors the Python `cookbook/pocketflow-hello-world` structure:

### Python Structure → Motoko Equivalent

| Python File | Motoko Equivalent | Purpose |
|-------------|-------------------|---------|
| `main.py` | `examples/hello-world/main.mo` | Main workflow execution |
| `flow.py` | `examples/hello-world/main.mo` (AnswerNode class) | Node and Flow definitions |
| `utils/call_llm.py` | `examples/hello-world/llm_mock.mo` | LLM service integration |

### Python Code → Motoko Code

**Python main.py:**
```python
def main():
    shared = {
        "question": "In one sentence, what's the end of universe?",
        "answer": None
    }
    qa_flow.run(shared)
    print("Question:", shared["question"])
    print("Answer:", shared["answer"])
```

**Motoko equivalent:**
```motoko
public func test() : async Text {
    let question = "In one sentence, what's the end of universe?";
    let answer = await run_workflow(question);
    "Question: " # question # " | Answer: " # answer
}
```

**Python flow.py:**
```python
class AnswerNode(Node):
    def prep(self, shared):
        return shared["question"]
    
    def exec(self, question):
        return call_llm(question)
    
    def post(self, shared, prep_res, exec_res):
        shared["answer"] = exec_res
```

**Motoko equivalent:**
```motoko
private class AnswerNode() {
    public func prep(question: Text) : Text { question };
    public func exec(question: Text) : async Text { await call_llm(question) };
    public func post(answer: Text) : Text { answer };
    public func run(question: Text) : async Text {
        let prepResult = prep(question);
        let execResult = await exec(prepResult);
        post(execResult)
    };
}
```

## 📦 Deployed Canisters

### 1. Hello World Example (`hello_world_example`)
- **Purpose**: Main PocketFlow workflow demonstrating the AnswerNode pattern
- **Methods**:
  - `test()` - Runs the default question from Python example
  - `run_workflow(question: Text)` - Execute workflow with custom question
  - `test_meaning_of_life()` - Test with "meaning of life" question
  - `test_custom(question: Text)` - Test with any custom question
  - `health()` - Health check

### 2. LLM Mock Service (`llm_mock_service`)
- **Purpose**: Simulates OpenAI API calls from Python's `call_llm.py`
- **Methods**:
  - `call_llm(prompt: Text)` - Main LLM simulation
  - `call_llm_with_model(prompt: Text, model: Text)` - Model-specific responses
  - `call_llm_batch(prompts: [Text])` - Batch processing
  - `test()` - Quick test
  - `health()` - Health check
  - `get_categories()` - Available response categories

## 🧪 Testing & Validation

### Manual Testing Commands

```bash
# Test basic workflow (mirrors Python main.py)
dfx canister call hello_world_example test

# Test with custom question
dfx canister call hello_world_example run_workflow '("What is blockchain?")'

# Test LLM mock directly
dfx canister call llm_mock_service call_llm '("Hello, world!")'

# Test meaning of life (should return "42")
dfx canister call hello_world_example test_meaning_of_life
```

### Integration Tests
```bash
scripts/test-integration.bat
```

This runs comprehensive tests that validate:
- ✅ Python workflow compatibility
- ✅ AnswerNode prep→exec→post pattern  
- ✅ LLM mock service responses
- ✅ Error handling and edge cases
- ✅ Health checks and service status

## 🌐 Web Interface

### Launch Methods

1. **Automatic (with canister ID detection):**
   ```bash
   scripts/launch-frontend.bat
   ```

2. **Manual (simple HTML opening):**
   ```bash
   scripts/open-frontend.bat
   ```

### Frontend Features
- 🎨 Beautiful, responsive design
- 🔌 Direct canister integration
- 📝 Custom question input
- 📊 Real-time results display
- 📱 Mobile-friendly interface
- ⚡ No build process required

### Usage
1. Enter your canister ID (auto-detected if using launch script)
2. Click "Test Example" for default Python question
3. Or enter custom question and click "Run Workflow"
4. View PocketFlow workflow results in real-time

## 🔧 Development & Debugging

### Get Canister IDs
```bash
scripts/get-canister-id.bat
```

### Manual Commands
```bash
# Enter development environment
docker-compose exec dfx bash

# Inside container:
source ~/.local/share/dfx/env
dfx canister status hello_world_example
dfx canister call hello_world_example test
```

### Logs & Debugging
```bash
# View container logs
docker-compose logs dfx

# Debug specific issues
scripts/debug-container.bat
```

## 🔄 Development Workflow

### 1. Code Changes
Edit files in:
- `examples/hello-world/main.mo` - Main workflow logic
- `examples/hello-world/llm_mock.mo` - LLM service
- `examples/hello-world/frontend/` - Web interface

### 2. Redeploy
```bash
scripts/deploy-pocketflow.bat
```

### 3. Test
```bash
scripts/test-integration.bat
```

### 4. Validate Frontend
```bash
scripts/open-frontend.bat
```

## 🌟 Key Features Demonstrated

### Python Compatibility
- ✅ **AnswerNode Pattern**: prep→exec→post workflow
- ✅ **Flow Execution**: Sequential node processing
- ✅ **Shared State**: Parameter passing between steps
- ✅ **LLM Integration**: Mock service for AI responses
- ✅ **Error Handling**: Graceful failure management

### Internet Computer Advantages
- ✅ **Decentralized**: No single point of failure
- ✅ **Permanent**: Code and data persist on-chain
- ✅ **Web-native**: Direct browser integration
- ✅ **Scalable**: Automatic scaling and load balancing
- ✅ **Secure**: Cryptographic verification of execution

### Real-world Applications
- 🤖 **AI Workflows**: Chain LLM calls with logic
- 📊 **Data Processing**: Sequential data transformation
- 🔄 **Business Logic**: Multi-step decision processes
- 🌐 **Web Services**: Decentralized API endpoints
- 🔗 **Blockchain Integration**: On-chain workflow execution

## 📚 Next Steps

### 1. Real LLM Integration
Replace mock service with actual OpenAI/Anthropic APIs:
- Implement HTTP outcalls
- Add API key management
- Handle rate limiting and retries

### 2. Advanced Workflows
Extend to more complex patterns:
- Multi-node flows
- Conditional branching
- Parallel execution
- State persistence

### 3. Production Deployment
Deploy to IC mainnet:
- Update network configuration
- Optimize for production
- Set up monitoring and alerts

### 4. Integration with Python
Create bridges between Python and Motoko:
- HTTP APIs for cross-platform integration
- Shared data formats
- Common workflow definitions

This implementation provides a complete, working PocketFlow system on the Internet Computer that maintains compatibility with the Python cookbook while leveraging IC's unique capabilities! 🎉