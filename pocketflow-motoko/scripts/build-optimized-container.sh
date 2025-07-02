#!/bin/bash

echo
echo "=========================================="
echo " Building Optimized PocketFlow Container"
echo "=========================================="
echo
echo "This will build a cached Docker image to avoid"
echo "re-downloading Ubuntu packages on every startup."
echo

# Enable Docker BuildKit for better caching
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

echo "[INFO] Building optimized Docker image..."
echo "This may take a few minutes on first build, but will be much faster afterwards."
echo

# Build the image with proper caching
docker-compose build --parallel

if [ $? -eq 0 ]; then
    echo
    echo "[SUCCESS] Optimized container built successfully!"
    echo
    echo "=========================================="
    echo " Caching Benefits"
    echo "=========================================="
    echo
    echo "✅ Ubuntu packages cached - no re-download"
    echo "✅ DFX installation cached - no re-install"
    echo "✅ System dependencies cached"
    echo "✅ Vessel package manager cached"
    echo "✅ DFX configuration persisted"
    echo "✅ Deployed canisters persisted"
    echo
    echo "Next runs will be much faster!"
    echo
    echo "To use the optimized container:"
    echo "  docker-compose up -d"
    echo "  scripts/deploy-pocketflow.sh"
    echo
else
    echo
    echo "[ERROR] Failed to build optimized container."
    echo
    echo "Troubleshooting:"
    echo "1. Make sure Docker Desktop is running"
    echo "2. Check Docker has enough disk space"
    echo "3. Try: docker system prune -f"
    echo "4. Retry the build"
    echo
fi

# Optional: uncomment the next line if you want to pause like the Windows version
# read -p "Press [Enter] key to continue..."
