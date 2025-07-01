# PocketFlow Motoko Development Makefile

.PHONY: help docker-up docker-down docker-shell test deploy clean install

# Default target
help:
	@echo "PocketFlow Motoko Development Commands"
	@echo "====================================="
	@echo ""
	@echo "Docker Commands:"
	@echo "  docker-up    - Start Docker development environment"
	@echo "  docker-down  - Stop Docker development environment"
	@echo "  docker-shell - Open shell in development container"
	@echo ""
	@echo "Development Commands:"
	@echo "  install      - Install dependencies"
	@echo "  test         - Run quick tests"
	@echo "  deploy       - Deploy all canisters"
	@echo "  clean        - Clean build artifacts"
	@echo ""
	@echo "Example Usage:"
	@echo "  make docker-up && make docker-shell"
	@echo "  # Then inside container: make test"

# Docker commands
docker-up:
	@echo "🐋 Starting Docker development environment..."
	docker-compose up -d
	@echo "✅ Docker environment started"
	@echo "   Run 'make docker-shell' to enter the container"

docker-down:
	@echo "🐋 Stopping Docker development environment..."
	docker-compose down
	@echo "✅ Docker environment stopped"

docker-shell:
	@echo "🐋 Opening shell in development container..."
	docker-compose exec dfx bash

# Development commands (can be run in Docker or natively)
install:
	@echo "📦 Installing dependencies..."
	vessel install
	@echo "✅ Dependencies installed"

test:
	@echo "🧪 Running PocketFlow tests..."
	./scripts/quick-test.sh

deploy:
	@echo "🚀 Deploying all canisters..."
	dfx start --background
	dfx deploy
	@echo "✅ All canisters deployed"

clean:
	@echo "🧹 Cleaning build artifacts..."
	dfx stop || true
	rm -rf .dfx
	@echo "✅ Build artifacts cleaned"

# Development workflow shortcuts
dev-start: docker-up
	@echo "🚀 Starting development workflow..."
	@echo "   1. Docker environment is running"
	@echo "   2. Run 'make docker-shell' to enter container"
	@echo "   3. Run 'make test' inside container to test"

dev-stop: docker-down clean

# Quick commands for inside Docker container
quick-test:
	@echo "⚡ Quick test (for use inside Docker)..."
	dfx start --background --host 0.0.0.0
	dfx deploy
	dfx canister call hello_world_example test
	@echo "✅ Quick test completed"

# Show container logs
logs:
	docker-compose logs -f dfx

# Reset everything
reset: docker-down clean
	@echo "🔄 Resetting entire development environment..."
	docker-compose down -v
	docker system prune -f
	@echo "✅ Environment reset complete"