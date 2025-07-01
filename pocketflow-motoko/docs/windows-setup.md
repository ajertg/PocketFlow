# Windows Setup Guide for PocketFlow Motoko

## Quick Setup for Windows Users

### Prerequisites
1. **Docker Desktop for Windows** - [Download here](https://www.docker.com/products/docker-desktop/)
2. **Git Bash** (which you already have)

### Step-by-Step Instructions

#### 1. Start Docker Desktop
- Open Docker Desktop from your Start menu
- Wait for it to fully start (you'll see "Docker Desktop is running" in the system tray)
- Make sure it shows "Engine running" in the Docker Desktop interface

#### 2. Open Git Bash Terminal
- Open Git Bash (not regular Command Prompt or PowerShell)
- Navigate to your PocketFlow directory:
```bash
cd /c/Users/everiale/source/repos/PocketFlow/pocketflow-motoko
```

#### 3. Check Docker is Working
```bash
# Test Docker is accessible from Git Bash
docker --version
docker-compose --version
```

You should see version numbers for both commands.

#### 4. Start the Development Environment

**Option A: Use the Windows batch script (easiest)**
```bash
# From Git Bash, run the Windows batch script
scripts/start-dev.bat
```

**Option B: Use Docker commands directly**
```bash
# Start the Docker containers
docker-compose up -d
```

This will:
- Pull the DFINITY Docker image (first time only - may take a few minutes)
- Start the development container
- Set up networking and volumes

#### 5. Enter the Development Container

**Option A: Use the batch script**
```bash
# Run tests automatically in container
scripts/test-in-container.bat
```

**Option B: Enter container manually**
```bash
# Open a shell inside the container
docker-compose exec dfx bash
```

You're now inside a Linux container with all the DFINITY tools installed!

#### 6. Run the Tests
Inside the container, run:
```bash
# Run the automated test suite
./scripts/quick-test.sh
```

This will:
- Start the IC replica
- Deploy PocketFlow library
- Deploy examples
- Run tests
- Show you the results

### What You Should See

When successful, you'll see output like:
```
🚀 PocketFlow Motoko Quick Test
================================
[INFO] Running in Docker environment
[SUCCESS] DFX found: dfx 0.15.1
[INFO] Starting IC replica...
[SUCCESS] IC replica is running
[SUCCESS] Core library deployed
[SUCCESS] Hello World example deployed
[SUCCESS] Hello World test passed!
  Result: ("The answer to 'In one sentence, what's the end of universe?' is 42, according to the Internet Computer!")
```

### Accessing the Web Interface

After the tests run, you can access:
- **Candid UI**: http://localhost:8000/_/candid
- **Individual canisters**: URLs will be shown in the test output

### Common Windows Issues & Solutions

#### Issue 1: Docker not found
```bash
# If you get "docker: command not found"
# Make sure Docker Desktop is running and restart Git Bash
```

#### Issue 2: Permission errors
```bash
# If you get permission errors, try:
winpty docker-compose exec dfx bash
# instead of
make docker-shell
```

#### Issue 3: Port conflicts
```bash
# If port 8000 is in use, you can modify docker-compose.yml
# Change "8000:8000" to "8001:8000" and use localhost:8001 instead
```

#### Issue 4: Make command not found (SOLVED)
Since Git Bash doesn't include `make` by default, use these alternatives:

**Use the provided batch scripts:**
```bash
# Start development environment
scripts/start-dev.bat

# Run tests in container
scripts/test-in-container.bat
```

**Or use Docker commands directly:**
```bash
# Start environment
docker-compose up -d

# Enter container manually
docker-compose exec dfx bash

# Inside container, run tests
./scripts/quick-test.sh
```

### Development Workflow

Once everything is working:

1. **Start development** (from Git Bash):
```bash
# Easy way: use the batch script
scripts/start-dev.bat

# Manual way: use docker-compose
docker-compose up -d
docker-compose exec dfx bash
```

2. **Inside the container**, you can:
```bash
# Test changes
./scripts/quick-test.sh

# Deploy manually
dfx deploy

# Call functions directly
dfx canister call hello_world_example test
dfx canister call hello_world_example run_workflow '("Your question here")'
```

3. **Stop development** (from Git Bash):
```bash
docker-compose down
```

### Editing Files

You can edit the Motoko files (.mo) using:
- **VS Code** (recommended): Open the pocketflow-motoko folder
- **Any text editor**: Files are in the mounted volume, so changes persist

The Docker container automatically sees your file changes!

### File Paths in Git Bash vs Container

- **Git Bash path**: `/c/Users/everiale/source/repos/PocketFlow/pocketflow-motoko`
- **Container path**: `/workspace` (automatically mapped)

### Troubleshooting Commands

```bash
# Check if Docker is running
docker ps

# Check container logs
docker-compose logs dfx

# Reset everything if stuck
make docker-down
docker system prune -f
make docker-up
```

### Next Steps

Once you have this working:
1. Try modifying the examples in `examples/hello-world/main.mo`
2. Create your own workflow nodes
3. Test with the Candid UI at http://localhost:8000/_/candid

This setup gives you a complete Internet Computer development environment running in Docker, accessible from your familiar Git Bash terminal!