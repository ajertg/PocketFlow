#!/bin/bash

# Setup script to install DFX in Ubuntu container
set -e

echo "🚀 Setting up DFINITY development environment..."

# Update package list
apt-get update -y

# Install required packages
apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libunwind-dev \
    ca-certificates \
    wget \
    git

echo "📦 Installing DFX..."

# Install DFX
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Source the dfx environment
source "$HOME/.local/share/dfx/env"

# Add DFX to PATH (new location)
export PATH="/root/.local/share/dfx/bin:$PATH"
echo 'export PATH="/root/.local/share/dfx/bin:$PATH"' >> /root/.bashrc

# Verify installation
echo "✅ DFX installed successfully:"
dfx --version

# Install Vessel (package manager)
echo "📦 Installing Vessel..."
wget https://github.com/dfinity/vessel/releases/latest/download/vessel-linux64 -O /usr/local/bin/vessel
chmod +x /usr/local/bin/vessel

echo "✅ Vessel installed successfully:"
vessel --version

# Make scripts executable
chmod +x /workspace/scripts/*.sh

echo "🎉 Setup complete! Ready for PocketFlow development."
echo ""
echo "Next steps:"
echo "  1. Run: /workspace/scripts/quick-test.sh"
echo "  2. Or start manually: dfx start --background --host 0.0.0.0"