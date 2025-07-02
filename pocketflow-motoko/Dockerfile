# PocketFlow Motoko Development Environment
# Based on the official ICP development environment

# Use the official ICP dev environment as base - this includes DFX, Node.js, Rust, and all necessary tools
FROM ghcr.io/dfinity/icp-dev-env:latest

# Set working directory
WORKDIR /workspace

# Install Vessel package manager for Motoko dependencies
RUN curl -L -o /usr/local/bin/vessel https://github.com/dfinity/vessel/releases/latest/download/vessel-linux64 \
    && chmod +x /usr/local/bin/vessel

# Create workspace structure for PocketFlow
RUN mkdir -p /workspace/.dfx /workspace/src /workspace/examples

# Copy PocketFlow source code
COPY . /workspace/

# Set proper ownership
RUN chown -R root:root /workspace

# Health check to ensure DFX is working
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD dfx --version || exit 1

# Default command
CMD ["bash"]
