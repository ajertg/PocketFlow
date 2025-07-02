#!/bin/bash

# Debug script to check what's running in the container
set -e

echo "🔍 PocketFlow Container Debug Info"
echo "=================================="

# Set PATH
export PATH="/root/bin:$PATH"

echo "📋 System Info:"
echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "  User: $(whoami)"
echo "  Working Dir: $(pwd)"
echo

echo "📦 Installed Tools:"
if command -v dfx &> /dev/null; then
    echo "  ✅ DFX: $(dfx --version)"
else
    echo "  ❌ DFX: Not installed"
fi

if command -v vessel &> /dev/null; then
    echo "  ✅ Vessel: $(vessel --version)"
else
    echo "  ❌ Vessel: Not installed"
fi

echo

echo "🌐 Network Info:"
echo "  Hostname: $(hostname)"
echo "  IP: $(hostname -I || echo 'Unknown')"
echo

echo "🔌 Port Status:"
netstat -tlnp 2>/dev/null | grep -E ':(8000|8080|4943)' || echo "  No services on ports 8000, 8080, 4943"

echo

echo "📁 Project Files:"
ls -la /workspace/ | head -10

echo

echo "🚀 DFX Status:"
if command -v dfx &> /dev/null; then
    echo "  Checking DFX networks..."
    dfx ping local 2>&1 || echo "  Local network not responding"
    
    echo "  Checking if replica is running..."
    pgrep -f replica || echo "  No replica process found"
    
    echo "  DFX Identity:"
    dfx identity whoami 2>&1 || echo "  No identity set"
else
    echo "  DFX not available"
fi

echo
echo "🎯 Recommendations:"
echo "  1. If DFX not installed: run /workspace/scripts/setup-container.sh"
echo "  2. If replica not running: run 'dfx start --background --host 0.0.0.0'"
echo "  3. If ports not accessible: check Docker port mapping"
echo "  4. Test direct canister calls instead of web interface"