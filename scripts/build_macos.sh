#!/usr/bin/env bash
#
# MoonBrook Ridge — One-command macOS build
#
# Usage:
#   ./scripts/build_macos.sh                  # Debug client+server build
#   ./scripts/build_macos.sh --release        # Release build
#   ./scripts/build_macos.sh --server-only    # Headless server (no graphics)
#   ./scripts/build_macos.sh --no-install     # Skip Homebrew package installation
#   ./scripts/build_macos.sh --help           # Show usage
#
# This script installs the required Homebrew packages, runs CMake, and
# compiles the project.  When it finishes you will have ready-to-run
# binaries in the bin/ directory.
#
set -euo pipefail

# ── Defaults ────────────────────────────────────────────────────────
BUILD_TYPE="Debug"
BUILD_CLIENT="TRUE"
BUILD_SERVER="TRUE"
INSTALL_DEPS="true"

# ── Parse arguments ────────────────────────────────────────────────
show_help() {
    cat <<'EOF'
MoonBrook Ridge — macOS build helper

Usage: ./scripts/build_macos.sh [OPTIONS]

Options:
  --release        Build in Release mode (default: Debug)
  --server-only    Build the dedicated server only (no graphics libs needed)
  --no-install     Skip automatic Homebrew package installation
  --help           Show this help message

After a successful build the binaries are located in:
  bin/moonbrook_ridge        — graphical client + integrated server
  bin/moonbrook_ridgeserver  — dedicated headless server
EOF
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --release)      BUILD_TYPE="Release" ;;
        --server-only)  BUILD_CLIENT="FALSE"; BUILD_SERVER="TRUE" ;;
        --no-install)   INSTALL_DEPS="false" ;;
        --help|-h)      show_help ;;
        *)              echo "Unknown option: $arg"; show_help ;;
    esac
done

# ── Locate repo root (script may be invoked from anywhere) ─────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "========================================"
echo " MoonBrook Ridge — macOS Build"
echo "========================================"
echo " Build type   : $BUILD_TYPE"
echo " Build client : $BUILD_CLIENT"
echo " Build server : $BUILD_SERVER"
echo " Repo root    : $REPO_ROOT"
echo "========================================"

# ── Install dependencies via Homebrew ──────────────────────────────
install_deps() {
    if [ "$INSTALL_DEPS" = "false" ]; then
        echo ">> Skipping dependency installation (--no-install)."
        return
    fi

    echo ""
    echo ">> Checking for Homebrew..."

    if ! command -v brew &>/dev/null; then
        echo "   Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo ">> Installing required Homebrew packages..."
    local pkgs=(
        cmake gmp jsoncpp sqlite zstd
        luajit gettext
    )
    if [ "$BUILD_CLIENT" = "TRUE" ]; then
        pkgs+=(
            freetype jpeg-turbo libpng libogg libvorbis
            openal-soft sdl2
        )
    fi
    brew install "${pkgs[@]}"
}

# ── Build ───────────────────────────────────────────────────────────
install_deps

NPROC=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 2)

echo ""
echo ">> Configuring with CMake..."
cmake -B build \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_FIND_FRAMEWORK=LAST \
    -DRUN_IN_PLACE=TRUE \
    -DBUILD_CLIENT="$BUILD_CLIENT" \
    -DBUILD_SERVER="$BUILD_SERVER" \
    -DBUILD_UNITTESTS=TRUE

echo ""
echo ">> Building (using $NPROC parallel jobs)..."
cmake --build build --parallel "$NPROC"

echo ""
echo "========================================"
echo " Build complete!"
echo "========================================"
echo ""
echo " Binaries are in: $REPO_ROOT/bin/"
[ "$BUILD_CLIENT" = "TRUE" ] && echo "   • Client+Server : bin/moonbrook_ridge"
[ "$BUILD_SERVER" = "TRUE" ] && echo "   • Dedicated      : bin/moonbrook_ridgeserver"
echo ""
echo " Quick start:  ./bin/moonbrook_ridge"
echo " Unit tests:   ./bin/moonbrook_ridge --run-unittests"
echo "========================================"
