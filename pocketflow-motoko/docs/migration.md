# Migration Guide: Python PocketFlow to Motoko

This guide provides a comprehensive walkthrough for porting Python PocketFlow applications to Motoko for the Internet Computer.

## Overview

PocketFlow Motoko maintains the same conceptual model as the Python version while adapting to Motoko's type system and the Internet Computer's actor model.

## Core Concept Mappings

### 1. Classes to Actors/Modules

**Python:**
```python
class MyNode(Node):
    def __init__(self, param1, param2):
        super().__init__()
        self.param1 = param1
        self.param2 = param2
```

**Motoko:**
```motoko
public class MyNode(param1: Text, param2: Nat) : PocketFlow.NodeInterface {
    public let maxRetries = 1;
    public let waitTime = 0;
    private let param1 = param1;
    private let param2 = param2;
}
```

### 2. Dictionary to SharedStore

**Python:**
```python
shared = {
    "input": "Hello World",
    "output": None,
    "count": 42
}

# Access
value = shared["input"]
shared["output"] = "Result"
```

**Motoko:**
```motoko
var shared = PocketFlow.newStore();
shared := PocketFlow.setInStore(shared, "input", PocketFlow.textValue("Hello World"));
shared := PocketFlow.setInStore(shared, "output", PocketFlow.textValue(""));
shared := PocketFlow.setInStore(shared, "count", PocketFlow.natValue(42));

// Access
switch (PocketFlow.getFromStore(shared, "input")) {
    case (?value) {
        switch (PocketFlow.extractText(value)) {
            case (?text) { /* use text */ };
            case null { /* handle error */ };
        }
    };
    case null { /* key not found */ };
}

// Update
shared := PocketFlow.setInStore(shared, "output", PocketFlow.textValue("Result"));
```

### 3. Exception Handling to Result Types

**Python:**
```python
def exec(self, prep_res):
    try:
        result = some_operation(prep_res)
        return result
    except Exception as e:
        raise e
```

**Motoko:**
```motoko
public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
    switch (some_operation(prepRes)) {
        case (#ok(result)) { #success(result) };
        case (#err(msg)) { #error(msg) };
    }
}
```

### 4. Inheritance to Composition

**Python:**
```python
class MyBatchNode(BatchNode):
    def exec(self, item):
        return process_item(item)
```

**Motoko:**
```motoko
public class MyBatchNode() : PocketFlow.BatchNode {
    public func execSingle(item: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        #success(process_item(item))
    };
}
```

## Step-by-Step Migration Process

### Step 1: Identify Node Types

Analyze your Python nodes and categorize them:

```python
# Simple processing node
class ProcessNode(Node): pass

# Batch processing node  
class BatchProcessNode(BatchNode): pass

# Async node
class AsyncProcessNode(AsyncNode): pass

# Flow controller
class MyFlow(Flow): pass
```

Map to Motoko equivalents:
- `Node` → `PocketFlow.NodeInterface`
- `BatchNode` → `PocketFlow.BatchNode`  
- `AsyncNode` → Built-in async support
- `Flow` → `PocketFlow.Flow`

### Step 2: Convert Node Lifecycle Methods

**Python Pattern:**
```python
class DataProcessor(Node):
    def prep(self, shared):
        return shared["data"]
    
    def exec(self, data):
        processed = transform_data(data)
        return processed
    
    def post(self, shared, prep_res, exec_res):
        shared["result"] = exec_res
        return "next_step"
```

**Motoko Pattern:**
```motoko
public class DataProcessor() : PocketFlow.NodeInterface {
    public let maxRetries = 1;
    public let waitTime = 0;
    
    public func prep(shared: PocketFlow.SharedStore) : async PocketFlow.StoreValue {
        switch (PocketFlow.getFromStore(shared, "data")) {
            case (?data) { data };
            case null { PocketFlow.textValue("") };
        }
    };
    
    public func exec(data: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        let processed = transform_data(data);
        #success(processed)
    };
    
    public func post(shared: PocketFlow.SharedStore, prepRes: PocketFlow.StoreValue, execRes: PocketFlow.StoreValue) : async ?PocketFlow.ActionName {
        // Note: Motoko's immutable stores require different handling
        ?"next_step"
    };
}
```

### Step 3: Handle Shared State Differences

**Python (mutable):**
```python
def post(self, shared, prep_res, exec_res):
    shared["result"] = exec_res  # Direct mutation
    shared["count"] += 1
```

**Motoko (immutable patterns):**
```motoko
// Option 1: Use actor state (for canister-level persistence)
actor DataProcessor {
    private stable var results: [(Text, Text)] = [];
    private stable var count: Nat = 0;
    
    public func updateState(key: Text, value: Text) {
        results := Array.append(results, [(key, value)]);
        count += 1;
    };
}

// Option 2: Return updates for external handling
public func post(shared: PocketFlow.SharedStore, prepRes: PocketFlow.StoreValue, execRes: PocketFlow.StoreValue) : async ?PocketFlow.ActionName {
    // Caller must handle state updates
    ?"next_step"
};
```

### Step 4: Convert Flow Setup

**Python:**
```python
# Create nodes
input_node = InputNode()
process_node = ProcessNode()  
output_node = OutputNode()

# Connect with transitions
input_node >> process_node >> output_node
input_node - "error" >> error_handler

# Create flow
flow = Flow(start=input_node)
flow.run(shared)
```

**Motoko:**
```motoko
// Create nodes
let inputNode = InputNode();
let processNode = ProcessNode();
let outputNode = OutputNode();
let errorHandler = ErrorHandler();

// Create flow and connect
let flow = PocketFlow.Flow();
flow.setStart(inputNode);
flow.addSuccessor(inputNode, "default", processNode);
flow.addSuccessor(processNode, "default", outputNode);
flow.addSuccessor(inputNode, "error", errorHandler);

// Run flow
let result = await flow.run(shared);
```

### Step 5: Handle Async Patterns

**Python:**
```python
class AsyncDataFetcher(AsyncNode):
    async def exec_async(self, prep_res):
        response = await http_client.get(url)
        return response.json()
```

**Motoko:**
```motoko
public class AsyncDataFetcher() : PocketFlow.NodeInterface {
    public let maxRetries = 3;
    public let waitTime = 1_000_000_000; // 1 second
    
    public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        switch (PocketFlow.extractText(prepRes)) {
            case (?url) {
                // Use IC HTTP outcalls
                let request = {
                    url = url;
                    headers = [];
                    body = null;
                    method = #get;
                };
                
                try {
                    let response = await IC.http_request(request);
                    #success(PocketFlow.textValue(response.body))
                } catch (e) {
                    #error("HTTP request failed: " # Error.message(e))
                }
            };
            case null { #error("Invalid URL") };
        }
    };
}
```

## Common Migration Patterns

### 1. File I/O to Stable Memory

**Python:**
```python
def read_file(filename):
    with open(filename, 'r') as f:
        return f.read()
```

**Motoko:**
```motoko
import StableMemory "mo:base/ExperimentalStableMemory";

stable var fileContents: [(Text, Text)] = [];

public func readFile(filename: Text) : ?Text {
    switch (Array.find(fileContents, func((name, _)) = name == filename)) {
        case (?(_, content)) { ?content };
        case null { null };
    }
}
```

### 2. External API Calls

**Python:**
```python
import requests

def call_api(url, data):
    response = requests.post(url, json=data)
    return response.json()
```

**Motoko:**
```motoko
import IC "mo:base/ExperimentalInternetComputer";

public func callAPI(url: Text, data: Text) : async Text {
    let request = {
        url = url;
        headers = [("Content-Type", "application/json")];
        body = ?Text.encodeUtf8(data);
        method = #post;
    };
    
    let response = await IC.http_request(request);
    Text.decodeUtf8(response.body)
}
```

### 3. Batch Processing

**Python:**
```python
class BatchProcessor(BatchNode):
    def _exec(self, items):
        return [self.exec(item) for item in items]
```

**Motoko:**
```motoko
public class BatchProcessor() : PocketFlow.BatchNode {
    public func processBatch(items: [PocketFlow.StoreValue]) : async [PocketFlow.NodeResult<PocketFlow.StoreValue>] {
        let futures = Array.map(items, func(item) { execSingle(item) });
        // In real implementation, would use proper async coordination
        futures
    };
}
```

## Testing Migration

### Unit Test Comparison

**Python:**
```python
def test_node():
    node = MyNode()
    shared = {"input": "test"}
    result = node.run(shared)
    assert shared["output"] == "expected"
```

**Motoko:**
```motoko
import Debug "mo:base/Debug";

public func testNode() : async Bool {
    let node = MyNode();
    var shared = PocketFlow.newStore();
    shared := PocketFlow.setInStore(shared, "input", PocketFlow.textValue("test"));
    
    let result = await node.run(shared);
    
    switch (PocketFlow.getFromStore(shared, "output")) {
        case (?output) {
            switch (PocketFlow.extractText(output)) {
                case (?"expected") { true };
                case _ { false };
            }
        };
        case null { false };
    }
}
```

## Deployment Considerations

### 1. Canister Architecture

**Single Canister (Simple Apps):**
```motoko
actor WorkflowEngine {
    // All nodes and flows in one canister
    let flow = PocketFlow.Flow();
    // ... implementation
}
```

**Multi-Canister (Complex Apps):**
```motoko
// Main orchestrator canister
actor FlowOrchestrator {
    // Coordinates between worker canisters
}

// Worker canisters for distributed processing
actor WorkerNode1 {
    // Specialized processing logic
}
```

### 2. State Management

Use stable variables for upgrade-safe persistence:

```motoko
actor WorkflowEngine {
    private stable var workflowState: [(Text, PocketFlow.StoreValue)] = [];
    private stable var completedRuns: Nat = 0;
    
    system func preupgrade() {
        // Prepare state for upgrade
    };
    
    system func postupgrade() {
        // Restore state after upgrade
    };
}
```

## Performance Optimization

### 1. Memory Usage
- Use stable memory for large datasets
- Prefer streaming over bulk operations
- Implement pagination for large result sets

### 2. Instruction Limits
- Break large operations into smaller chunks
- Use heartbeat for long-running processes
- Implement checkpointing for resumable workflows

### 3. Cycles Management
- Monitor cycles consumption
- Implement cost controls
- Use efficient data structures

This migration guide provides the foundation for successfully porting Python PocketFlow applications to the Internet Computer while leveraging Motoko's type safety and IC's unique capabilities.