# PocketFlow Motoko

A minimalist workflow orchestration library for the Internet Computer, ported from the original [PocketFlow](https://github.com/The-Pocket/PocketFlow) Python library.

## Overview

PocketFlow Motoko brings the elegant simplicity of PocketFlow's workflow engine to the Internet Computer ecosystem. It maintains the core 100-line philosophy while leveraging IC's unique capabilities like async inter-canister calls, stable memory, and the actor model.

## Key Features

- **Minimalist Design**: Core engine under 150 lines of Motoko code
- **IC-Native**: Built for Internet Computer's actor model and async patterns
- **Type Safe**: Leverages Motoko's strong type system
- **Distributed**: Support for inter-canister workflow execution
- **Persistent**: Uses stable variables for upgrade-safe state
- **Compatible**: Direct ports of Python PocketFlow patterns

## Quick Start

### Windows Users (Git Bash)
👉 **See [Windows Setup Guide](docs/windows-setup.md)** for step-by-step instructions using Docker Desktop + Git Bash.

### Docker Setup (Recommended)

The fastest way to get started is using Docker:

```bash
# Clone and enter the project
cd pocketflow-motoko

# Start the development environment
make docker-up

# Enter the container
make docker-shell

# Run the quick test script
./scripts/quick-test.sh
```

### Manual Installation

Add to your `vessel.dhall`:
```dhall
{
  dependencies = [ "base", "pocketflow" ],
  compiler = Some "0.10.1"
}
```

### Basic Usage

```motoko
import PocketFlow "mo:pocketflow";
import Types "mo:pocketflow/types";

// Define a simple node
class GreetingNode() : Types.NodeInterface {
  public func prep(shared : Types.SharedStore) : async Text {
    switch (Types.getFromStore(shared, "name")) {
      case (?name) { name };
      case null { "World" };
    }
  };

  public func exec(name : Text) : async Types.NodeResult<Text> {
    #success("Hello, " # name # "!")
  };

  public func post(shared : Types.SharedStore, prep_res : Text, exec_res : Text) : async ?Text {
    Types.setInStore(shared, "greeting", exec_res);
    null // No next action
  };

  public let maxRetries = 1;
  public let waitTime = 0;
};

// Create and run a simple flow
let node = GreetingNode();
let flow = PocketFlow.Flow();
flow.setStart(node);

let shared = Types.newStore();
Types.setInStore(shared, "name", "IC Developer");
let result = await flow.run(shared);
```

## Core Concepts

### Nodes
Nodes are the basic building blocks that encapsulate logic with three lifecycle methods:
- `prep()`: Prepare input data from shared state
- `exec()`: Execute the core logic
- `post()`: Process results and determine next action

### Flows
Flows orchestrate node execution, managing:
- Sequential execution
- Conditional transitions
- Shared state management
- Error handling and retries

### Shared Store
A type-safe key-value store that flows between nodes, enabling:
- Data persistence across nodes
- State management
- Inter-node communication

## Examples

### Hello World
```bash
dfx deploy hello_world_example
dfx canister call hello_world_example run_workflow '("Your Name")'
```

### Map-Reduce Pattern
```bash
dfx deploy map_reduce_example
dfx canister call map_reduce_example process_batch '(vec {"item1"; "item2"; "item3"})'
```

### Async Workflows
```bash
dfx deploy async_example
dfx canister call async_example run_async_flow '()'
```

## Architecture

PocketFlow Motoko is designed around IC's actor model:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flow Actor    │───▶│   Node Actor    │───▶│  External API   │
│                 │    │                 │    │   (HTTP Out)    │
│ • Orchestration │    │ • prep()        │    │                 │
│ • State Mgmt    │    │ • exec()        │    └─────────────────┘
│ • Transitions   │    │ • post()        │
└─────────────────┘    └─────────────────┘
         │                       │
         │              ┌─────────────────┐
         └─────────────▶│  Stable Memory  │
                        │                 │
                        │ • Workflow State│
                        │ • Shared Store  │
                        └─────────────────┘
```

## Migration from Python

PocketFlow Motoko provides a near 1:1 mapping from the Python version:

| Python | Motoko | Notes |
|--------|--------|-------|
| `BaseNode` | `NodeInterface` | Interface instead of base class |
| `Flow` | `Flow` | Direct equivalent with async methods |
| `shared` dict | `SharedStore` | Type-safe key-value store |
| `successors` | `successors` | Same conditional transition logic |
| Exception handling | `Result` types | Type-safe error handling |

## Development

### Prerequisites
- [DFX](https://internetcomputer.org/docs/current/developer-docs/setup/install/) >= 0.15.0
- [Vessel](https://github.com/dfinity/vessel) for package management

### Build
```bash
dfx start --background
dfx deploy
```

### Test
```bash
dfx canister call test_runner run_all_tests
```

### Examples
```bash
# Run all examples
dfx deploy --network local

# Individual examples
dfx canister call hello_world_example run_workflow '("Test")'
dfx canister call map_reduce_example process_data '(vec {1; 2; 3; 4; 5})'
```

## API Reference

See [docs/api.md](docs/api.md) for complete API documentation.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Original [PocketFlow](https://github.com/The-Pocket/PocketFlow) Python library
- Internet Computer community
- DFINITY Foundation for Motoko and IC infrastructure