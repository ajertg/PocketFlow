#!/bin/bash

# Setup script for PocketFlow in official ICP dev environment
set -e

echo "🚀 Setting up PocketFlow environment..."

# Source the dfx environment (already available in official ICP dev environment)
source /root/.local/share/dfx/env 2>/dev/null || true

# Add DFX to PATH
export PATH="/root/.local/share/dfx/bin:$PATH"

# Verify DFX is available
echo "✅ DFX version:"
dfx --version

# Verify Vessel is available (installed in Dockerfile)
echo "✅ Vessel version:"
vessel --version

# Make scripts executable
chmod +x /workspace/scripts/*.sh

echo "🎉 PocketFlow environment ready!"
echo ""
echo "Next steps:"
echo "  1. Run: /workspace/scripts/quick-test.sh"
echo "  2. Or start manually: dfx start --background --host 0.0.0.0"
