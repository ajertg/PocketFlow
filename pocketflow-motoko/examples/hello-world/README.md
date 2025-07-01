# PocketFlow Motoko Hello World

A direct port of the Python PocketFlow hello-world example to Motoko for the Internet Computer.

## Overview

This example demonstrates the basic PocketFlow pattern:
1. **Node Creation**: A simple `GreetingNode` that processes questions
2. **Flow Setup**: Creating a flow with the node as the start point
3. **Execution**: Running the workflow with shared state

## Comparison with Python Version

### Python Original
```python
class AnswerNode(Node):
    def prep(self, shared):
        return shared["question"]
    
    def exec(self, question):
        return call_llm(question)
    
    def post(self, shared, prep_res, exec_res):
        shared["answer"] = exec_res

answer_node = AnswerNode()
qa_flow = Flow(start=answer_node)
```

### Motoko Port
```motoko
public class GreetingNode() : PocketFlow.NodeInterface {
    public func prep(shared: PocketFlow.SharedStore) : async PocketFlow.StoreValue {
        switch (PocketFlow.getFromStore(shared, "question")) {
            case (?value) { value };
            case null { PocketFlow.textValue("What is the meaning of life?") };
        }
    };
    
    public func exec(question: PocketFlow.StoreValue) : async PocketFlow.NodeResult<PocketFlow.StoreValue> {
        // Mock LLM response - in real version would use HTTP outcalls
        #success(PocketFlow.textValue("Answer: 42!"))
    };
    
    public func post(shared: PocketFlow.SharedStore, prepRes: PocketFlow.StoreValue, execRes: PocketFlow.StoreValue) : async ?PocketFlow.ActionName {
        null // No next action
    };
};

let greetingNode = GreetingNode();
let flow = PocketFlow.Flow();
flow.setStart(greetingNode);
```

## Key Differences

1. **Type Safety**: Motoko's strong typing requires explicit type annotations
2. **Async by Default**: All methods are async to support IC's execution model
3. **Immutable State**: SharedStore uses immutable data structures
4. **Error Handling**: Uses Result types instead of exceptions
5. **Actor Model**: Deployed as a canister with public methods

## Usage

### Deploy and Test
```bash
# Start local IC replica
dfx start --background

# Deploy the canister
dfx deploy hello_world_example

# Test the workflow
dfx canister call hello_world_example test

# Run with custom question
dfx canister call hello_world_example run_workflow '("What is the meaning of life?")'
```

### Expected Output
```
("The answer to 'What is the meaning of life?' is 42, according to the Internet Computer!")
```

## Integration with IC Features

This example can be enhanced with:

1. **HTTP Outcalls**: Replace mock responses with real LLM API calls
2. **Inter-canister Calls**: Distribute nodes across multiple canisters
3. **Stable Memory**: Persist workflow state across upgrades
4. **Timers**: Add delays and scheduling capabilities

## Next Steps

1. Add HTTP outcalls for real LLM integration
2. Implement proper error handling and retries
3. Add workflow monitoring and logging
4. Create more complex multi-node examples