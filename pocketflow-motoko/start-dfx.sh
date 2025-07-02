#!/bin/bash

echo "🚀 Starting DFX for PocketFlow (Persistent Mode)..."

# Setup DFX environment
export PATH="/root/.local/share/dfx/bin:$PATH"
export DFX_NETWORK=local

# Change to workspace directory
cd /workspace

echo "DFX version: $(dfx --version)"

# Kill any existing DFX processes
pkill -f dfx || true

# Start DFX replica in foreground (will keep the process alive)
echo "Starting DFX replica on 0.0.0.0:8000..."
exec dfx start --host 0.0.0.0:8000
