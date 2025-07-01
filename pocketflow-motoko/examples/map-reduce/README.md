# PocketFlow Motoko Map-Reduce Example

A port of the Python PocketFlow map-reduce pattern demonstrating distributed data processing workflows on the Internet Computer.

## Overview

This example demonstrates a three-phase workflow pattern:
1. **Read Phase**: Prepare data for processing
2. **Map Phase**: Process individual items in parallel (batch processing)
3. **Reduce Phase**: Aggregate results into final output

This mirrors the Python cookbook example that processes resumes to determine candidate qualifications.

## Workflow Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   ReadDataNode  │───▶│ EvaluateResumeNode│───▶│ ReduceResultsNode│
│                 │    │                  │    │                 │
│ • Load resumes  │    │ • Evaluate each  │    │ • Count results │
│ • Prepare data  │    │ • Apply criteria │    │ • Generate summary│
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Comparison with Python Version

### Python Original
```python
class ReadResumesNode(Node):
    def exec(self, _):
        # Read files from disk
        return resume_files
    
class EvaluateResumesNode(BatchNode):
    def exec(self, resume_item):
        # Call LLM to evaluate resume
        return evaluation
        
class ReduceResultsNode(Node):
    def exec(self, evaluations):
        # Aggregate results
        return summary
```

### Motoko Port
```motoko
public class ReadDataNode() : PocketFlow.NodeInterface {
    public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        // Mock resume data (in real version would read from stable memory)
        let sampleResumes = [...];
        #success(PocketFlow.textValue(Text.join("|", sampleResumes.vals())))
    };
};

public class EvaluateResumeNode() : PocketFlow.BatchNode {
    public func execSingle(resume: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        // Simple qualification logic (mock LLM evaluation)
        let qualifies = /* evaluation logic */;
        #success(PocketFlow.textValue(result))
    };
};

public class ReduceResultsNode() : PocketFlow.NodeInterface {
    public func exec(evaluations: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        // Count and summarize results
        #success(PocketFlow.textValue(summary))
    };
};
```

## Key IC Enhancements

This Motoko version can leverage IC-specific features:

### 1. Inter-canister Parallelism
```motoko
// Distribute evaluation across multiple canisters
let evaluatorCanisterIds = ["canister1", "canister2", "canister3"];
for (resume in resumes.vals()) {
    let canisterId = selectCanister(resume);
    let evaluation = await IC.call(canisterId, "evaluate", resume);
};
```

### 2. Stable Memory for Large Datasets
```motoko
import StableMemory "mo:base/ExperimentalStableMemory";

// Store large resume datasets in stable memory
stable var resumeData : [(Text, Text)] = [];
```

### 3. HTTP Outcalls for Real LLM Integration
```motoko
import HTTP "mo:base/ExperimentalInternetComputer";

public func callLLM(prompt: Text) : async Text {
    let request = {
        url = "https://api.openai.com/v1/completions";
        headers = [("Authorization", "Bearer " # apiKey)];
        body = /* JSON payload */;
    };
    let response = await HTTP.request(request);
    // Parse and return response
};
```

## Usage

### Deploy and Test
```bash
# Start local IC replica
dfx start --background

# Deploy the canister
dfx deploy map_reduce_example

# Run the map-reduce workflow
dfx canister call map_reduce_example test

# Process custom data
dfx canister call map_reduce_example process_batch '(vec {"Resume 1"; "Resume 2"; "Resume 3"})'
```

### Expected Output
```
("Summary: 1 qualified candidates found")
```

## Extending the Example

### 1. Real File Processing
Replace mock data with actual file reading from stable memory or HTTP outcalls to external storage.

### 2. Parallel Processing
Implement true parallel batch processing by distributing work across multiple canisters:

```motoko
public class ParallelEvaluateNode() : PocketFlow.BatchNode {
    let workerCanisters = ["worker1", "worker2", "worker3"];
    
    public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        let items = parseItems(prepRes);
        let futures = Array.map(items, func(item) {
            let workerId = selectWorker(item);
            IC.call(workerId, "process", item)
        });
        let results = await Promise.all(futures);
        #success(aggregateResults(results))
    };
};
```

### 3. Error Handling and Retries
Leverage PocketFlow's built-in retry mechanism:

```motoko
let evaluateNode = EvaluateResumeNode();
evaluateNode.maxRetries := 5;
evaluateNode.waitTime := 2_000_000_000; // 2 seconds
```

### 4. Monitoring and Observability
Add logging and metrics:

```motoko
import Debug "mo:base/Debug";
import Time "mo:base/Time";

public func exec(prepRes: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
    let startTime = Time.now();
    Debug.print("Starting evaluation at: " # Int.toText(startTime));
    
    let result = await evaluateResume(prepRes);
    
    let endTime = Time.now();
    Debug.print("Evaluation completed in: " # Int.toText(endTime - startTime) # "ns");
    
    result
};
```

## Production Considerations

1. **Memory Management**: Use stable memory for large datasets
2. **Error Recovery**: Implement comprehensive error handling
3. **Performance**: Optimize for IC's instruction limits
4. **Scalability**: Design for horizontal scaling across canisters
5. **Cost Optimization**: Minimize cycles consumption

This example provides a foundation for building complex data processing workflows on the Internet Computer using PocketFlow's workflow orchestration patterns.