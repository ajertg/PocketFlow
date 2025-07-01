# PocketFlow Test Example

A simple example demonstrating PocketFlow's core concepts and architectural patterns.

## Project Structure

```
pocketflow-test/
├── docs/
│   └── design.md       # Design documentation
├── utils/
│   └── call_llm.py     # LLM utility functions
├── flow.py             # Node and flow definitions
├── main.py            # Application entry point
└── README.md          # This file
```

## Features

- Basic PocketFlow node implementation
- Documentation-first approach
- Proper separation of concerns
- Interactive user input handling
- LLM integration (mock implementation)

## Key Concepts Demonstrated

1. **Documentation-First**: Complete design doc before implementation
2. **Node Architecture**: Using prep/exec/post pattern
3. **Shared Store**: Proper state management
4. **Flow Design**: Simple flow with self-loop

## Running the Example

1. Make sure you have PocketFlow installed:
```bash
pip install pocketflow
```

2. Run the example:
```bash
python main.py
```

## Project Organization

- **docs/design.md**: Complete design documentation
- **utils/call_llm.py**: Mock LLM integration
- **flow.py**: Node and flow implementation
- **main.py**: Application entry point
