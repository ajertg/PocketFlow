# Docker Optimization Guide for PocketFlow Motoko

This guide explains how we've optimized Docker layer caching to avoid re-downloading Ubuntu packages and dependencies on every startup.

## 🚀 Quick Start (Optimized)

```bash
# First time setup (builds cached image)
scripts/build-optimized-container.bat

# Fast subsequent starts
docker-compose up -d
scripts/deploy-pocketflow.bat
```

## 🎯 Optimization Strategies Implemented

### 1. **Multi-Stage Dockerfile with Layer Caching**

**File:** `Dockerfile`

```dockerfile
# Cache-friendly: Install system dependencies first (changes rarely)
RUN apt-get update && apt-get install -y \
    build-essential pkg-config ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Cache-friendly: Install DFX (version-specific, cache when version doesn't change)
ENV DFX_VERSION=0.27.0
RUN curl -fsSL https://internetcomputer.org/install.sh | sh

# This layer only rebuilds if source code changes
COPY . /workspace/
```

**Benefits:**
- ✅ Ubuntu packages cached (no re-download)
- ✅ DFX installation cached (no re-install)
- ✅ Only source code changes trigger rebuild

### 2. **Docker Compose with Persistent Volumes**

**File:** `docker-compose.yml`

```yaml
volumes:
  # Persistent caches - survive container restarts
  dfx_cache:/root/.cache/dfinity
  dfx_local:/root/.local/share/dfx
  dfx_config:/root/.config/dfx
  workspace_dfx:/workspace/.dfx  # Deployed canisters persist!
```

**Benefits:**
- ✅ DFX cache persisted between runs
- ✅ Deployed canisters survive container restarts
- ✅ Configuration preserved
- ✅ Only mount source code that changes

### 3. **Optimized Build Context**

**File:** `.dockerignore`

```
# Exclude unnecessary files from build context
.git/
docs/
*.log
.dfx/local/
```

**Benefits:**
- ✅ Faster build context transfer
- ✅ Smaller image size
- ✅ Better layer caching

### 4. **BuildKit Optimization**

**Enabled in:** `scripts/build-optimized-container.bat`

```bash
set DOCKER_BUILDKIT=1
set COMPOSE_DOCKER_CLI_BUILD=1
```

**Benefits:**
- ✅ Parallel layer building
- ✅ Better cache management
- ✅ Faster builds

## 📊 Performance Comparison

### Before Optimization (Every `docker-compose up`):
```
⏱️  Ubuntu download: ~2-3 minutes
⏱️  Package install: ~2-3 minutes  
⏱️  DFX install: ~1-2 minutes
⏱️  Setup: ~1 minute
📦  Total: 6-9 minutes every time
```

### After Optimization (First build):
```
⏱️  First build: ~6-9 minutes (same as before)
🚀  Subsequent starts: ~10-30 seconds!
📦  Total time saved: 5-8 minutes per restart
```

## 🛠️ Usage Instructions

### First Time Setup
```bash
# Build the optimized image (one time)
scripts/build-optimized-container.bat

# Start using it
docker-compose up -d
scripts/deploy-pocketflow.bat
```

### Daily Development Workflow
```bash
# Fast restart (uses cached image)
docker-compose up -d          # ~10-30 seconds

# Deploy your changes
scripts/deploy-pocketflow.bat  # ~1-2 minutes

# Test
scripts/test-integration.bat
```

### Force Rebuild (When Needed)
```bash
# If you need to update system dependencies
docker-compose build --no-cache
```

## 🗂️ What Gets Cached

### ✅ Cached (Persistent)
- Ubuntu base image and packages
- DFX installation and binaries
- Vessel package manager
- System dependencies (build-essential, etc.)
- DFX configuration (`~/.config/dfx/`)
- DFX cache (`~/.cache/dfinity/`)
- **Deployed canisters** (`workspace/.dfx/`)

### 🔄 Not Cached (Fresh on Change)
- Source code (`src/`, `examples/`)
- Scripts (`scripts/`)
- Configuration (`dfx.json`)

## 🧪 Testing Cache Effectiveness

```bash
# Test 1: Time a fresh start
time docker-compose up -d

# Test 2: Check what's cached
docker volume ls | grep pocketflow

# Test 3: Verify canister persistence
scripts/deploy-pocketflow.bat
docker-compose restart
scripts/get-canister-id.bat  # Should show same IDs
```

## 🔧 Cache Management

### View Cache Usage
```bash
# See volume sizes
docker system df -v

# List PocketFlow volumes
docker volume ls | grep pocketflow
```

### Clean Cache (If Needed)
```bash
# Clean everything (force fresh start)
docker-compose down -v
docker system prune -a

# Rebuild optimized image
scripts/build-optimized-container.bat
```

### Selective Cleanup
```bash
# Keep image, clean volumes only
docker-compose down -v

# Keep everything, restart container
docker-compose restart
```

## 🏗️ Architecture Benefits

### Development Speed
- ✅ **Fast iterations**: Change code → deploy in ~1-2 minutes
- ✅ **Consistent environment**: Same setup every time
- ✅ **No setup time**: DFX already installed and configured

### Resource Efficiency
- ✅ **Bandwidth savings**: No re-downloading packages
- ✅ **Disk efficiency**: Shared layers across rebuilds
- ✅ **CPU savings**: No recompiling system dependencies

### Production Readiness
- ✅ **Reproducible builds**: Same image every time
- ✅ **Version control**: Pin DFX and package versions
- ✅ **Environment parity**: Dev matches production

## 🎯 Advanced Optimizations

### Multi-Architecture Support
```yaml
# In docker-compose.yml (future enhancement)
platform: linux/amd64,linux/arm64
```

### Remote Cache (Team Development)
```bash
# Share cached layers across team
docker buildx create --use
docker buildx build --cache-from=type=registry --cache-to=type=registry
```

### Production Optimization
```dockerfile
# Multi-stage build for production
FROM base AS development
FROM base AS production
RUN rm -rf /workspace/docs /workspace/scripts/*.bat
```

This optimization dramatically improves the development experience by eliminating the 5-8 minute wait time for Ubuntu package downloads on every container restart! 🚀