#!/usr/bin/env bash
#
# MoonBrook Ridge — Automated Setup & Build
#
# Detects your operating system, installs all required dependencies,
# and builds MoonBrook Ridge from source in a single command.
#
# Usage:
#   ./scripts/setup.sh                    # Debug client+server build
#   ./scripts/setup.sh --release          # Release (optimised) build
#   ./scripts/setup.sh --server-only      # Headless server (no graphics)
#   ./scripts/setup.sh --no-install       # Skip dependency installation
#   ./scripts/setup.sh --help             # Show usage
#
set -euo pipefail

# ── Locate repo root (script may be invoked from anywhere) ─────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_help() {
    cat <<'EOF'
MoonBrook Ridge — Automated Setup & Build

Detects your operating system and runs the appropriate build script
that installs dependencies and compiles the project.

Usage: ./scripts/setup.sh [OPTIONS]

Options:
  --release        Build in Release mode (default: Debug)
  --server-only    Build the dedicated server only (no graphics libs needed)
  --no-install     Skip automatic dependency installation
  --help           Show this help message

Supported Platforms:
  Linux    — Debian/Ubuntu, Fedora/RHEL, Arch, Alpine, openSUSE
  macOS    — via Homebrew
  Windows  — use .\scripts\build_windows.bat or .\scripts\build_windows.ps1

After a successful build the binaries are located in:
  bin/moonbrook_ridge        — graphical client + integrated server
  bin/moonbrook_ridgeserver  — dedicated headless server
EOF
    exit 0
}

# Check for --help before forwarding
for arg in "$@"; do
    case "$arg" in
        --help|-h) show_help ;;
    esac
done

# ── Detect OS and delegate ─────────────────────────────────────────
OS="$(uname -s)"

case "$OS" in
    Linux)
        echo ">> Detected Linux — running scripts/build_linux.sh"
        exec "$SCRIPT_DIR/build_linux.sh" "$@"
        ;;
    Darwin)
        echo ">> Detected macOS — running scripts/build_macos.sh"
        exec "$SCRIPT_DIR/build_macos.sh" "$@"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo ">> Detected Windows (MSYS/MinGW/Cygwin environment)"
        echo ""
        echo "   For the best Windows build experience, use one of:"
        echo "     PowerShell:  .\\scripts\\build_windows.ps1"
        echo "     CMD:         scripts\\build_windows.bat"
        echo ""
        echo "   These scripts set up vcpkg, install dependencies, configure"
        echo "   CMake with Visual Studio presets, and produce a .sln file."
        exit 1
        ;;
    *)
        echo "ERROR: Unsupported operating system '$OS'."
        echo ""
        echo "Supported platforms:"
        echo "  Linux    — ./scripts/build_linux.sh"
        echo "  macOS    — ./scripts/build_macos.sh"
        echo "  Windows  — .\\scripts\\build_windows.bat or .\\scripts\\build_windows.ps1"
        echo ""
        echo "See BUILDING.md for manual build instructions."
        exit 1
        ;;
esac
