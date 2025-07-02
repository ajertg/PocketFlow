#!/bin/bash

# PocketFlow Motoko Quick Test Script
# This script sets up the development environment and runs basic tests

set -e

echo "🚀 PocketFlow Motoko Quick Test"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in Docker or native environment
if [ -f /.dockerenv ]; then
    print_status "Running in Docker environment"
    IN_DOCKER=true
else
    print_status "Running in native environment"
    IN_DOCKER=false
fi

# Set PATH to include DFX (new location)
export PATH="/root/.local/share/dfx/bin:$PATH"
# Source dfx environment if available
[ -f "$HOME/.local/share/dfx/env" ] && source "$HOME/.local/share/dfx/env"

# Check if DFX is installed, if not install it
if ! command -v dfx &> /dev/null; then
    print_warning "DFX not found. Installing..."
    if [ -f "/workspace/scripts/setup-container.sh" ]; then
        /workspace/scripts/setup-container.sh
    else
        print_error "Setup script not found. Please run setup manually."
        exit 1
    fi
fi

print_success "DFX found: $(dfx --version)"

# Check if we're in the right directory
if [ ! -f "dfx.json" ]; then
    print_error "dfx.json not found. Please run this script from the pocketflow-motoko root directory"
    exit 1
fi

print_status "Starting IC replica..."

# Start DFX (background mode)
if $IN_DOCKER; then
    dfx start --background --host 0.0.0.0:8000
else
    dfx start --background
fi

# Wait for replica to be ready
print_status "Waiting for replica to be ready..."
sleep 3

# Check if replica is running
if dfx ping local &> /dev/null; then
    print_success "IC replica is running"
else
    print_error "Failed to start IC replica"
    exit 1
fi

print_status "Deploying PocketFlow core library..."

# Deploy core library
if dfx deploy pocketflow_core; then
    print_success "Core library deployed"
else
    print_error "Failed to deploy core library"
    dfx stop
    exit 1
fi

print_status "Deploying Hello World example..."

# Deploy hello world example
if dfx deploy hello_world_example; then
    print_success "Hello World example deployed"
else
    print_error "Failed to deploy Hello World example"
    dfx stop
    exit 1
fi

print_status "Testing Hello World example..."

# Test hello world
HELLO_RESULT=$(dfx canister call hello_world_example test 2>/dev/null || echo "ERROR")

if [[ $HELLO_RESULT == *"42"* ]]; then
    print_success "Hello World test passed!"
    echo "  Result: $HELLO_RESULT"
else
    print_error "Hello World test failed"
    echo "  Result: $HELLO_RESULT"
fi

print_status "Deploying Map-Reduce example..."

# Deploy map-reduce example
if dfx deploy map_reduce_example; then
    print_success "Map-Reduce example deployed"
else
    print_warning "Failed to deploy Map-Reduce example (may have compilation issues)"
fi

print_status "Testing Map-Reduce example..."

# Test map-reduce
MAP_RESULT=$(dfx canister call map_reduce_example test 2>/dev/null || echo "ERROR")

if [[ $MAP_RESULT == *"Summary"* ]]; then
    print_success "Map-Reduce test passed!"
    echo "  Result: $MAP_RESULT"
else
    print_warning "Map-Reduce test had issues"
    echo "  Result: $MAP_RESULT"
fi

echo ""
echo "🎉 PocketFlow Motoko Test Complete!"
echo "=================================="
print_status "Canister URLs:"

# Get canister IDs and show URLs
HELLO_ID=$(dfx canister id hello_world_example 2>/dev/null || echo "unknown")
MAP_ID=$(dfx canister id map_reduce_example 2>/dev/null || echo "unknown")

if $IN_DOCKER; then
    echo "  Hello World: http://localhost:8000/?canisterId=$HELLO_ID"
    echo "  Map-Reduce:  http://localhost:8000/?canisterId=$MAP_ID"
    echo "  Candid UI:   http://localhost:8000/_/candid"
else
    echo "  Hello World: http://127.0.0.1:8000/?canisterId=$HELLO_ID"
    echo "  Map-Reduce:  http://127.0.0.1:8000/?canisterId=$MAP_ID"
    echo "  Candid UI:   http://127.0.0.1:8000/_/candid"
fi

echo ""
print_status "Try these commands:"
echo "  dfx canister call hello_world_example run_workflow '(\"Your question here\")'"
echo "  dfx canister call map_reduce_example process_batch '(vec {\"item1\"; \"item2\"})'"

echo ""
print_warning "Remember to stop the replica when done:"
echo "  dfx stop"

print_success "PocketFlow Motoko is ready for development! 🎯"