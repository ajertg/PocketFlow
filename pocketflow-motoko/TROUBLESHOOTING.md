# PocketFlow Motoko - Troubleshooting Guide

Common issues and solutions for deploying PocketFlow on the Internet Computer.

## 🚨 Common Issues

### 1. "Docker build fails with exit code 127"

**Error:**
```
failed to solve: process "/bin/sh -c curl -fsSL https://internetcomputer.org/install.sh | bash" did not complete successfully: exit code 127
```

**Solution:**
This issue has been resolved by switching to the official ICP development environment as the base Docker image. The new Dockerfile uses `ghcr.io/dfinity/icp-dev-env:latest` which includes DFX, Node.js, Rust, and all necessary tools pre-installed.

**Rebuild the container:**
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

**Root Cause:** Previously, we were trying to install DFX manually in Alpine/Ubuntu, which had compatibility issues. Now we use the official ICP dev environment that's maintained by DFINITY.

**Additional Issues:** 
- If you see `wget: not found` during Vessel installation, this is because the official ICP dev environment doesn't include wget. The Dockerfile has been updated to use `curl` instead.
- If the container keeps restarting with `tail: command not found` or `sleep: command not found`, this is because the official ICP dev environment doesn't include these commands. The docker-compose.yml has been updated to use `while true; do read -t 30 || true; done` instead, which uses bash built-ins.

### 2. "dfx cannot connect to the local replica"

**Error:** 
```
Error: You are trying to connect to the local replica but dfx cannot connect to it.
To fix: Target a different network or run 'dfx start' to start the local replica.
```

**Solution:**
```bash
# Make sure the container is rebuilt with the latest fixes
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Start the IC replica with the fixed script
scripts/start-replica.bat

# Then deploy
scripts/deploy-pocketflow.bat
```

**Root Cause:** This can happen due to:
1. The IC replica not being started properly inside the container
2. Using old scripts that had `sleep` command issues in the official ICP dev environment
3. Network binding issues (now fixed with `--host 0.0.0.0`)

**Additional Fix:** The scripts have been updated to work with the official ICP dev environment which doesn't include `sleep` command.

### 3. "Vessel: GLIBC version not found"

**Error:**
```
vessel: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
```

**Solution:** This is a warning and doesn't affect functionality. Vessel is used for package management but isn't critical for our deployment.

### 4. "Invalid host" or "timeout: invalid time interval" errors

**Errors:**
```
Error: Invalid argument: Invalid host: invalid socket address syntax
timeout: invalid time interval '/t'
```

**Solution:** These issues have been fixed in the latest scripts:
- Removed incorrect `--host 0.0.0.0` flag from DFX start command
- The timeout commands are Windows batch commands that run on the host, not in the Linux container

**Note:** If you see timeout errors, it means the script is running inside the container instead of on the Windows host. Make sure to run `scripts/start-replica.bat` from your Windows terminal, not from inside the Docker container.

### 3. Empty Canister IDs

**Error:** Canister ID shows as empty or deployment fails silently.

**Solution:**
```bash
# Clean start
scripts/start-replica.bat

# Check status manually
docker-compose exec dfx bash
source ~/.local/share/dfx/env
dfx ping local
dfx deploy hello_world_example
```

### 4. Container Not Running

**Error:** Docker container not responding.

**Solution:**
```bash
# Restart everything
docker-compose down
docker-compose up -d

# Wait and try again
scripts/start-replica.bat
```

## 🔧 Manual Recovery Steps

### Complete Reset
```bash
# Stop everything
docker-compose down

# Clean up
docker-compose up -d

# Fresh start
scripts/start-replica.bat
scripts/deploy-pocketflow.bat
```

### Check Container Status
```bash
docker-compose ps
docker-compose logs dfx
```

### Manual DFX Commands
```bash
# Enter container
docker-compose exec dfx bash

# Inside container
source ~/.local/share/dfx/env
export PATH="/root/.local/share/dfx/bin:$PATH"

# Check dfx
dfx --version

# Start replica manually
dfx start --clean --background

# Deploy manually
dfx deploy hello_world_example
dfx deploy llm_mock_service
```

## 📝 Debugging Steps

### 1. Verify Environment
```bash
scripts/debug-container.bat
```

### 2. Check Replica Status
```bash
docker-compose exec dfx bash -c "source ~/.local/share/dfx/env && dfx ping local"
```

### 3. Test Simple Deployment
```bash
scripts/simple-test.bat
```

### 4. Manual Canister Testing
```bash
# Get canister ID
scripts/get-canister-id.bat

# Test directly
dfx canister call hello_world_example health
```

## 🎯 Working Command Sequence

If you encounter issues, try this exact sequence:

```bash
# 1. Clean start
docker-compose down
docker-compose up -d

# 2. Wait for container
timeout /t 10

# 3. Start replica properly
scripts/start-replica.bat

# 4. Deploy with proper ordering
scripts/deploy-pocketflow.bat

# 5. Test deployment
scripts/test-integration.bat

# 6. Open frontend
scripts/open-frontend.bat
```

## 📊 Success Indicators

You should see:
- ✅ "IC replica is running!"
- ✅ Canister IDs displayed (e.g., `u6s2n-gx777-77774-qaaba-cai`)
- ✅ Successful test calls returning responses
- ✅ Frontend loads with working interface

## 🌐 Browser Connection

Once your container is running (status "healthy"), follow these steps:

### 1. Deploy the Canisters First
```bash
# Start the IC replica
scripts/start-replica.bat

# Deploy PocketFlow canisters
scripts/deploy-pocketflow.bat
```

### 2. Available Browser URLs
After successful deployment, you can access:

- **DFX Dashboard**: http://localhost:4943
- **IC Replica**: http://localhost:8000
- **Candid UI**: http://localhost:8080
- **Frontend Example**: Use the frontend scripts or check deployed canister URLs

### 3. Quick Frontend Access
```bash
# Open the Hello World example frontend
scripts/open-frontend.bat

# Or manually open the deployed frontend URL shown after deployment
```

### 4. Verify Deployment
```bash
# Check if canisters are deployed
docker-compose exec dfx bash
dfx canister id hello_world_example
```

## 🆘 Last Resort

If nothing works:

1. **Check Docker:** Make sure Docker Desktop is running
2. **Restart System:** Sometimes a clean restart helps
3. **Manual Commands:** Use the manual DFX commands above
4. **Use Simple Test:** `scripts/simple-test.bat` as minimal test

## 📞 Getting Help

If issues persist:
1. Check `docker-compose logs dfx`
2. Try `scripts/debug-container.bat`
3. Use manual commands from container
4. Check that you're in the correct directory (`pocketflow-motoko/`)

The key is ensuring the IC replica starts successfully before any deployment attempts!
