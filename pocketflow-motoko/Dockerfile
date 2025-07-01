# Optimized Dockerfile for PocketFlow Motoko Development
# Uses layer caching to avoid re-downloading Ubuntu packages

FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Cache-friendly: Install system dependencies first (changes rarely)
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    ca-certificates \
    curl \
    git \
    libssl-dev \
    libunwind-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Cache-friendly: Create user and directories (changes rarely)
RUN useradd -m -s /bin/bash dfxuser
WORKDIR /workspace

# Cache-friendly: Install DFX (version-specific, cache when version doesn't change)
ENV DFX_VERSION=0.27.0
RUN curl -fsSL https://internetcomputer.org/install.sh | sh
ENV PATH="/root/.local/share/dfx/bin:$PATH"

# Cache-friendly: Install Vessel (version-specific)
RUN wget -O /usr/local/bin/vessel https://github.com/dfinity/vessel/releases/latest/download/vessel-linux64 \
    && chmod +x /usr/local/bin/vessel

# Cache-friendly: Setup DFX environment
RUN echo 'export PATH="/root/.local/share/dfx/bin:$PATH"' >> /root/.bashrc
RUN echo 'source /root/.local/share/dfx/env' >> /root/.bashrc

# Cache-friendly: Pre-create common directories
RUN mkdir -p /workspace/.dfx /workspace/src /workspace/examples

# This layer will only rebuild if source code changes
COPY . /workspace/

# Set proper ownership
RUN chown -R root:root /workspace

# Default command
CMD ["bash"]