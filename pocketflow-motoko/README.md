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
- **Official ICP Dev Environment**: Uses DFINITY's official Docker image for reliable development setup

## Quick Start

### Windows Users (Git Bash)
👉 **See [Windows Setup Guide](docs/windows-setup.md)** for step-by-step instructions using Docker Desktop + Git Bash.

### Docker Setup (Recommended)

The fastest way to get started is using Docker with the official ICP development environment:

```bash
# Clone and enter the project
cd pocketflow-motoko

# Build and start the optimized container
./scripts/build-optimized-container.sh
docker-compose up -d

# Start DFX in a persistent screen session
docker-compose exec dfx bash -c "
apt-get update -qq && apt-get install -y screen
screen -dmS dfx-session bash -c '
export PATH=\"/root/.local/share/dfx/bin:\$PATH\"
cd /workspace
dfx start --host 0.0.0.0:8000
'
"

# Deploy the example canisters
docker-compose exec dfx bash -c "
export PATH='/root/.local/share/dfx/bin:\$PATH'
cd /workspace
dfx deploy simple_test
"
```

#### Browser Access Points
Once DFX is running, you can access your canisters through:

- **Main Replica**: `http://localhost:8000`
- **Candid UI**: `http://localhost:8000/_/candid`
- **DFX Dashboard**: `http://localhost:4943`
- **Specific Canister**: `http://localhost:8000/?canisterId=<CANISTER_ID>`

#### Troubleshooting Container Issues

**If DFX fails to start or deploy fails:**

1. **Check container status**: `docker-compose ps`
2. **Restart container**: `docker-compose restart`
3. **Check DFX screen session**: `docker-compose exec dfx screen -list`
4. **View DFX logs**: `docker-compose exec dfx screen -S dfx-session -X hardcopy /tmp/dfx-output.txt && docker-compose exec dfx cat /tmp/dfx-output.txt`
5. **Manual DFX start**: Connect to container and run DFX manually

**Manual setup if automated script fails:**
```bash
# Enter the container
docker-compose exec dfx bash

# Setup environment and start DFX
export PATH="/root/.local/share/dfx/bin:$PATH"
cd /workspace
dfx start --host 0.0.0.0:8000

# In another terminal, deploy canisters
docker-compose exec dfx bash -c "
export PATH='/root/.local/share/dfx/bin:\$PATH'
cd /workspace
dfx deploy simple_test
dfx canister call simple_test test
"
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
- Docker (recommended for consistent environment)

### Build
```bash
# Using Docker (recommended)
docker-compose up -d
docker-compose exec dfx bash -c "
export PATH='/root/.local/share/dfx/bin:\$PATH'
cd /workspace
dfx start --background --host 0.0.0.0:8000
dfx deploy
"

# Using local DFX
dfx start --background
dfx deploy
```

### Test
```bash
# Test deployed canisters
dfx canister call simple_test test
dfx canister call simple_test greet '("PocketFlow Developer")'

# Run full test suite (when available)
dfx canister call test_runner run_all_tests
```

### Known Issues and Solutions

**Motoko Compilation Errors:**
- Fixed variable shadowing in `BaseNode` and `BatchNode` classes
- Parameter names changed from `maxRetries` to `maxRetriesParam` to avoid conflicts
- Type alias `Node = BaseNode` removed to fix forward reference issues

**DFX Network Configuration:**
- Updated `dfx.json` to use `"bind": "0.0.0.0:8000"` for container accessibility
- DFX must run with `--host 0.0.0.0:8000` flag in Docker environment
- Use screen sessions to maintain persistent DFX processes in containers

**Container Networking:**
- All ports properly mapped: 8000 (replica), 4943 (dashboard), 8080 (candid)
- DFX replica must bind to 0.0.0.0 to be accessible from host browser
- Screen utility required for persistent DFX sessions in Docker

## Recent Fixes (v0.1.1)

### Code Fixes
- **Fixed Motoko compilation errors** in `src/node.mo`:
  - Resolved variable shadowing by renaming parameters (`maxRetries` → `maxRetriesParam`)
  - Removed problematic type alias `Node = BaseNode` 
  - Simplified BatchNode implementation to avoid circular dependencies
  
- **Updated DFX configuration** in `dfx.json`:
  - Changed network bind from `127.0.0.1:8000` to `0.0.0.0:8000`
  - Ensures container accessibility from host browser

### Container Improvements  
- **Added persistent DFX startup script** (`start-dfx.sh`)
- **Enhanced deployment workflow** with proper environment setup
- **Added screen session management** for long-running DFX processes
- **Fixed port mapping issues** for browser accessibility

### Browser Access Verified
- ✅ Main replica: `http://localhost:8000`
- ✅ Candid UI: `http://localhost:8000/_/candid` 
- ✅ DFX Dashboard: `http://localhost:4943`
- ✅ Direct canister access: `http://localhost:8000/?canisterId=<ID>`

### Examples
```bash
# Start the container and DFX (if not already running)
docker-compose up -d
docker-compose exec dfx bash -c "
export PATH='/root/.local/share/dfx/bin:\$PATH'
cd /workspace
dfx start --background --host 0.0.0.0:8000
"

# Deploy and test examples
docker-compose exec dfx bash -c "
export PATH='/root/.local/share/dfx/bin:\$PATH'
cd /workspace

# Deploy simple test
dfx deploy simple_test
dfx canister call simple_test test
dfx canister call simple_test greet '(\"Test User\")'

# Deploy hello world example (when available)
# dfx canister call hello_world_example run_workflow '(\"Test\")'

# Deploy map-reduce example (when available)  
# dfx canister call map_reduce_example process_data '(vec {1; 2; 3; 4; 5})'
"

# Access via browser
echo "Open http://localhost:8000 in your browser"
echo "Candid UI: http://localhost:8000/_/candid"
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
