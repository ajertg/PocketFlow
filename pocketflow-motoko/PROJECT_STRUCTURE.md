# PocketFlow Motoko Project Structure

This document outlines the complete file structure for the PocketFlow Motoko port.

## Directory Layout

```
pocketflow-motoko/
├── src/
│   ├── lib.mo                 # Core PocketFlow library
│   ├── types.mo              # Type definitions
│   ├── node.mo               # Node implementations
│   ├── flow.mo               # Flow orchestrator
│   └── utils.mo              # Utility functions
├── examples/
│   ├── hello-world/
│   │   ├── main.mo           # Main canister
│   │   ├── flow.mo           # Flow implementation
│   │   └── README.md         # Example documentation
│   ├── map-reduce/
│   │   ├── main.mo           # Main canister
│   │   ├── nodes.mo          # Node implementations
│   │   ├── flow.mo           # Flow orchestration
│   │   └── README.md         # Example documentation
│   ├── async-basic/
│   │   ├── main.mo           # Async example
│   │   ├── flow.mo           # Async flow implementation
│   │   └── README.md         # Documentation
│   └── batch-parallel/
│       ├── main.mo           # Parallel batch processing
│       ├── nodes.mo          # Batch node implementations
│       ├── flow.mo           # Batch flow orchestration
│       └── README.md         # Documentation
├── tests/
│   ├── unit/
│   │   ├── test_node.mo      # Node unit tests
│   │   ├── test_flow.mo      # Flow unit tests
│   │   └── test_types.mo     # Type unit tests
│   └── integration/
│       ├── test_workflows.mo # End-to-end workflow tests
│       └── test_examples.mo  # Example integration tests
├── docs/
│   ├── api.md               # API documentation
│   ├── migration.md         # Python to Motoko migration guide
│   ├── examples.md          # Example usage patterns
│   └── deployment.md        # Deployment instructions
├── dfx.json                 # DFX configuration
├── vessel.dhall             # Package management
├── moc-args                 # Motoko compiler arguments
├── .gitignore               # Git ignore patterns
├── README.md                # Project overview
└── ARCHITECTURE_PLAN.md     # This planning document
```

## Core Files Description

### Configuration Files

#### dfx.json
```json
{
  "version": 1,
  "canisters": {
    "pocketflow_core": {
      "type": "motoko",
      "main": "src/lib.mo"
    },
    "hello_world_example": {
      "type": "motoko",
      "main": "examples/hello-world/main.mo"
    },
    "map_reduce_example": {
      "type": "motoko",
      "main": "examples/map-reduce/main.mo"
    }
  },
  "networks": {
    "local": {
      "bind": "127.0.0.1:8000",
      "type": "ephemeral"
    }
  }
}
```

#### vessel.dhall
```dhall
{
  dependencies = [ "base", "matchers" ],
  compiler = Some "0.10.1"
}
```

#### .gitignore
```
.dfx/
.vessel/
node_modules/
*.wasm
*.did
```

### Source Code Structure

#### src/types.mo
Core type definitions mirroring Python PocketFlow structure:
- `NodeId`, `ActionName`, `SharedStore`
- `NodeResult<T>` variant type
- `NodeInterface` with async methods
- `FlowConfig` and `Successor` types

#### src/node.mo
Base node implementations:
- `BaseNode` interface
- `Node` with retry logic
- `BatchNode` for batch processing
- `AsyncNode` for async operations

#### src/flow.mo
Flow orchestration logic:
- `Flow` class equivalent
- Conditional transition handling
- Node execution sequencing
- State management

#### src/lib.mo
Main library export with public API

#### src/utils.mo
Utility functions:
- Shared store manipulation
- Error handling helpers
- Timer utilities
- Type conversion functions

### Example Structure

Each example follows this pattern:
- `main.mo`: Main canister entry point with Candid interface
- `flow.mo`: Flow definition specific to the example
- `nodes.mo` (if needed): Custom node implementations
- `README.md`: Documentation and usage instructions

### Test Structure

#### Unit Tests
- Test individual components in isolation
- Mock dependencies where needed
- Focus on core logic verification

#### Integration Tests
- Test complete workflows end-to-end
- Verify inter-canister communication
- Test error handling and edge cases

## Implementation Priority

1. **Core Types** (`src/types.mo`)
2. **Base Node** (`src/node.mo`)
3. **Flow Orchestrator** (`src/flow.mo`)
4. **Library Export** (`src/lib.mo`)
5. **Hello World Example** (`examples/hello-world/`)
6. **Unit Tests** (`tests/unit/`)
7. **Additional Examples**
8. **Integration Tests**
9. **Documentation**

## Development Commands

```bash
# Start local replica
dfx start --background

# Deploy core library
dfx deploy pocketflow_core

# Deploy examples
dfx deploy hello_world_example

# Run tests
dfx canister call test_runner run_all_tests

# Build documentation
# (Custom script to generate API docs from source)
```

## Migration Notes

### From Python to Motoko

1. **Class -> Actor**: Python classes become Motoko actors/modules
2. **Dict -> AssocList**: Python dicts become Motoko association lists or Maps
3. **Exception -> Result**: Python exceptions become Result types
4. **async/await**: Direct translation to Motoko async/await
5. **Inheritance -> Composition**: Use composition instead of inheritance

### Key Differences

1. **Type Safety**: Motoko's strong typing requires explicit type annotations
2. **Memory Management**: No garbage collection, careful memory usage
3. **Actor Model**: Embrace message-passing instead of shared state
4. **Immutability**: Prefer immutable data structures
5. **Error Handling**: Use Result types instead of exceptions

This structure provides a solid foundation for the PocketFlow Motoko port while maintaining the simplicity of the original Python implementation.