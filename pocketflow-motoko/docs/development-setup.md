# Development Setup Guide

This guide helps you set up the DFINITY development environment to test and develop with PocketFlow Motoko.

## Option 1: DFINITY Docker Development Environment

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- [Git](https://git-scm.com/downloads) for cloning repositories

### Setup Steps

1. **Pull the DFINITY Docker image:**
```bash
docker pull ghcr.io/dfinity/sdk:latest
```

2. **Create a development container:**
```bash
# Navigate to the pocketflow-motoko directory
cd pocketflow-motoko

# Run Docker container with mounted volume
docker run -it --rm \
  -p 8000:8000 \
  -p 8080:8080 \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/dfinity/sdk:latest bash
```

3. **Inside the container, verify DFX installation:**
```bash
dfx --version
```

4. **Start the local IC replica:**
```bash
dfx start --background --host 0.0.0.0
```

5. **Deploy and test PocketFlow:**
```bash
# Deploy the core library
dfx deploy pocketflow_core

# Deploy and test hello world example
dfx deploy hello_world_example
dfx canister call hello_world_example test

# Test the map-reduce example
dfx deploy map_reduce_example
dfx canister call map_reduce_example test
```

### Docker Compose Alternative

Create a `docker-compose.yml` for easier development:

```yaml
services:
  dfx:
    image: ghcr.io/dfinity/sdk:latest
    ports:
      - "8000:8000"
      - "8080:8080"
    volumes:
      - .:/workspace
    working_dir: /workspace
    command: tail -f /dev/null
    environment:
      - DFX_NETWORK=local
```

Then run:
```bash
docker-compose up -d
docker-compose exec dfx bash
```

## Option 2: Native Installation

### macOS
```bash
# Install DFX
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Add to PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
dfx --version
```

### Linux (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt update
sudo apt install curl build-essential

# Install DFX
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Add to PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
dfx --version
```

### Windows (WSL2)
```bash
# Install WSL2 first, then follow Linux instructions
# Or use Docker Desktop with the Docker approach above
```

## Testing the Installation

### 1. Quick Test
```bash
cd pocketflow-motoko

# Start local replica
dfx start --background

# Deploy hello world
dfx deploy hello_world_example

# Test it works
dfx canister call hello_world_example test
```

### Expected Output
```
("The answer to 'In one sentence, what's the end of universe?' is 42, according to the Internet Computer!")
```

### 2. Development Workflow
```bash
# Make changes to source code
# Redeploy to test
dfx deploy --mode=reinstall

# View canister logs
dfx canister logs hello_world_example

# Stop local replica when done
dfx stop
```

## Troubleshooting

### Common Issues

1. **Port conflicts:**
```bash
# If port 8000 is in use
dfx start --background --port 8001
```

2. **Permission issues (Linux/macOS):**
```bash
# Make sure you have write permissions
chmod +x ~/.local/share/dfx/bin/dfx
```

3. **Docker networking (Docker setup):**
```bash
# If canisters aren't accessible from host
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -w /workspace \
  dfinity/dfx:latest bash
```

4. **Motoko compiler issues:**
```bash
# Update vessel packages
vessel install

# Check Motoko version
moc --version
```

### Debug Commands
```bash
# Check canister status
dfx canister status hello_world_example

# View canister info
dfx canister info hello_world_example

# Check local replica status
dfx ping local
```

## IDE Setup

### VS Code Extensions
1. **Motoko Language Support**: Install from VS Code marketplace
2. **DFINITY**: Official extension for IC development

### VS Code Settings
Add to `.vscode/settings.json`:
```json
{
  "motoko.vessel": true,
  "motoko.dfx": true,
  "files.associations": {
    "*.mo": "motoko"
  }
}
```

## Performance Tips

### Development Mode
```bash
# Faster compilation for development
export DFX_NETWORK=local
export VESSEL_PACKAGE_SET=https://github.com/dfinity/vessel-package-set/releases/latest/download/package-set.dhall
```

### Production Testing
```bash
# Test with production-like settings
dfx start --replica-version latest

# Deploy with optimization
dfx deploy --network local --with-cycles 1000000000000
```

## Next Steps

Once your environment is set up:

1. **Run the examples** to verify everything works
2. **Modify the code** to experiment with PocketFlow patterns
3. **Create your own nodes** following the examples
4. **Test with real HTTP outcalls** using the IC's HTTP outcall feature
5. **Deploy to the IC mainnet** when ready for production

## Getting Help

- [DFINITY Documentation](https://internetcomputer.org/docs/)
- [Motoko Language Guide](https://internetcomputer.org/docs/current/motoko/intro/)
- [DFINITY Forum](https://forum.dfinity.org/)
- [Discord Community](https://discord.gg/dfinity)

This setup will give you a complete development environment for working with PocketFlow Motoko on the Internet Computer.