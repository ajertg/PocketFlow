# PocketFlow Motoko - Troubleshooting Guide

Common issues and solutions for deploying PocketFlow on the Internet Computer.

## 🚨 Common Issues

### 1. "dfx cannot connect to the local replica"

**Error:** 
```
Error: You are trying to connect to the local replica but dfx cannot connect to it.
To fix: Target a different network or run 'dfx start' to start the local replica.
```

**Solution:**
```bash
# Start the IC replica first
scripts/start-replica.bat

# Then deploy
scripts/deploy-pocketflow.bat
```

**Root Cause:** The IC replica needs to be running before any deployment commands.

### 2. "Vessel: GLIBC version not found"

**Error:**
```
vessel: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
```

**Solution:** This is a warning and doesn't affect functionality. Vessel is used for package management but isn't critical for our deployment.

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