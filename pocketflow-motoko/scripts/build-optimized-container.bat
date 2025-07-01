@echo off
echo.
echo ==========================================
echo  Building Optimized PocketFlow Container
echo ==========================================
echo.
echo This will build a cached Docker image to avoid
echo re-downloading Ubuntu packages on every startup.
echo.

REM Enable Docker BuildKit for better caching
set DOCKER_BUILDKIT=1
set COMPOSE_DOCKER_CLI_BUILD=1

echo [INFO] Building optimized Docker image...
echo This may take a few minutes on first build, but will be much faster afterwards.
echo.

REM Build the image with proper caching
docker-compose build --parallel

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Optimized container built successfully!
    echo.
    echo ==========================================
    echo  Caching Benefits
    echo ==========================================
    echo.
    echo ✅ Ubuntu packages cached - no re-download
    echo ✅ DFX installation cached - no re-install  
    echo ✅ System dependencies cached
    echo ✅ Vessel package manager cached
    echo ✅ DFX configuration persisted
    echo ✅ Deployed canisters persisted
    echo.
    echo Next runs will be much faster!
    echo.
    echo To use the optimized container:
    echo   docker-compose up -d
    echo   scripts\deploy-pocketflow.bat
    echo.
) else (
    echo.
    echo [ERROR] Failed to build optimized container.
    echo.
    echo Troubleshooting:
    echo 1. Make sure Docker Desktop is running
    echo 2. Check Docker has enough disk space
    echo 3. Try: docker system prune -f
    echo 4. Retry the build
    echo.
)

pause