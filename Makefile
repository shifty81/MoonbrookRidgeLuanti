# MoonBrook Ridge — Convenience Makefile
#
# Quick reference:
#   make              — build (debug, client + server)
#   make build        — same as above
#   make release      — build in release mode
#   make server       — build server only (no graphics libs needed)
#   make test         — run C++ unit tests
#   make test-lua     — run Lua linting and unit tests (requires luacheck & busted)
#   make run          — launch the game client
#   make run-server   — launch the dedicated server
#   make clean        — remove build artifacts
#   make help         — show all targets

BUILD_DIR    := build
BUILD_TYPE   ?= Debug
NPROC        := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)
CLIENT_BIN   := bin/moonbrook_ridge
SERVER_BIN   := bin/moonbrook_ridgeserver

.PHONY: all build release server test test-lua run run-server clean help

all: build

## ── Build targets ──────────────────────────────────────────────────

build: ## Build client + server (Debug)
	cmake -B $(BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DRUN_IN_PLACE=TRUE \
		-DBUILD_CLIENT=TRUE \
		-DBUILD_SERVER=TRUE \
		-DBUILD_UNITTESTS=TRUE
	cmake --build $(BUILD_DIR) --parallel $(NPROC)
	@echo ""
	@echo "Build complete — binaries in bin/"

release: ## Build client + server (Release)
	$(MAKE) build BUILD_TYPE=Release

server: ## Build dedicated server only (no graphics)
	cmake -B $(BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DRUN_IN_PLACE=TRUE \
		-DBUILD_CLIENT=FALSE \
		-DBUILD_SERVER=TRUE \
		-DBUILD_UNITTESTS=TRUE
	cmake --build $(BUILD_DIR) --parallel $(NPROC)
	@echo ""
	@echo "Server build complete — $(SERVER_BIN)"

## ── Test targets ───────────────────────────────────────────────────

test: build ## Run C++ unit tests
	./$(CLIENT_BIN) --run-unittests

test-lua: ## Run Lua linting (luacheck) and unit tests (busted)
	@echo "── Luacheck ──"
	luacheck builtin
	@echo ""
	@echo "── Busted unit tests ──"
	busted builtin

## ── Run targets ────────────────────────────────────────────────────

run: build ## Launch the game client
	./$(CLIENT_BIN)

run-server: server ## Launch the dedicated server
	./$(SERVER_BIN)

## ── Maintenance ────────────────────────────────────────────────────

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
	@echo "Build directory removed."

## ── Help ───────────────────────────────────────────────────────────

help: ## Show available targets
	@echo "MoonBrook Ridge — Build Targets"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make                 Build debug client + server"
	@echo "  make release         Build optimised release"
	@echo "  make test            Build and run C++ unit tests"
	@echo "  make run             Build and launch the game"
	@echo "  make clean           Remove build directory"
