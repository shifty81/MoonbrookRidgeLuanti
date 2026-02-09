#!/usr/bin/env bash
#
# MoonBrook Ridge — One-command Linux build
#
# Usage:
#   ./scripts/build_linux.sh                  # Debug client+server build
#   ./scripts/build_linux.sh --release        # Release build
#   ./scripts/build_linux.sh --server-only    # Headless server (no graphics)
#   ./scripts/build_linux.sh --help           # Show usage
#
# This script detects your Linux distribution, installs the required
# development packages, runs CMake, and compiles the project.  When it
# finishes you will have ready-to-run binaries in the bin/ directory.
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
MoonBrook Ridge — Linux build helper

Usage: ./scripts/build_linux.sh [OPTIONS]

Options:
  --release        Build in Release mode (default: Debug)
  --server-only    Build the dedicated server only (no graphics libs needed)
  --no-install     Skip automatic dependency installation
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
echo " MoonBrook Ridge — Linux Build"
echo "========================================"
echo " Build type   : $BUILD_TYPE"
echo " Build client : $BUILD_CLIENT"
echo " Build server : $BUILD_SERVER"
echo " Repo root    : $REPO_ROOT"
echo "========================================"

# ── Detect distro and install dependencies ─────────────────────────
install_deps() {
    if [ "$INSTALL_DEPS" = "false" ]; then
        echo ">> Skipping dependency installation (--no-install)."
        return
    fi

    echo ""
    echo ">> Detecting Linux distribution..."

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-}"
    else
        DISTRO_ID="unknown"
        DISTRO_LIKE=""
    fi

    echo "   Detected: $DISTRO_ID ($DISTRO_LIKE)"

    # Common (non-graphics) packages by family
    case "$DISTRO_ID $DISTRO_LIKE" in
        *debian*|*ubuntu*|*pop*|*mint*|*kali*)
            install_debian ;;
        *fedora*|*rhel*|*centos*)
            install_fedora ;;
        *arch*|*manjaro*|*endeavour*)
            install_arch ;;
        *alpine*)
            install_alpine ;;
        *opensuse*|*suse*)
            install_suse ;;
        *)
            echo "   ⚠  Unsupported distribution '$DISTRO_ID'."
            echo "      Please install the required packages manually (see BUILDING.md)."
            echo "      Continuing with build — cmake will report any missing libraries."
            ;;
    esac
}

install_debian() {
    echo ">> Installing Debian/Ubuntu packages..."
    local pkgs=(
        g++ make cmake libc6-dev
        libsqlite3-dev libogg-dev libgmp-dev
        libcurl4-gnutls-dev libzstd-dev zlib1g-dev
        libjsoncpp-dev libluajit-5.1-dev gettext
    )
    if [ "$BUILD_CLIENT" = "TRUE" ]; then
        pkgs+=(
            libpng-dev libjpeg-dev libgl1-mesa-dev libsdl2-dev
            libfreetype6-dev libvorbis-dev libopenal-dev
        )
    fi
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends "${pkgs[@]}"
}

install_fedora() {
    echo ">> Installing Fedora/RHEL packages..."
    local pkgs=(
        make automake gcc gcc-c++ kernel-devel cmake
        sqlite-devel libogg-devel gmp-devel
        libcurl-devel libzstd-devel zlib-devel
        jsoncpp-devel luajit-devel gettext
    )
    if [ "$BUILD_CLIENT" = "TRUE" ]; then
        pkgs+=(
            libpng-devel libjpeg-turbo-devel mesa-libGL-devel SDL2-devel
            freetype-devel libvorbis-devel openal-soft-devel
        )
    fi
    sudo dnf install -y "${pkgs[@]}"
}

install_arch() {
    echo ">> Installing Arch packages..."
    local pkgs=(
        base-devel cmake sqlite libogg gmp
        curl zstd zlib jsoncpp luajit gettext
    )
    if [ "$BUILD_CLIENT" = "TRUE" ]; then
        pkgs+=(
            libpng libjpeg-turbo mesa sdl2
            freetype2 libvorbis openal
        )
    fi
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

install_alpine() {
    echo ">> Installing Alpine packages..."
    local pkgs=(
        build-base cmake sqlite-dev libogg-dev gmp-dev
        curl-dev zstd-dev zlib-dev jsoncpp-dev luajit-dev gettext
    )
    if [ "$BUILD_CLIENT" = "TRUE" ]; then
        pkgs+=(
            libpng-dev jpeg-dev mesa-dev sdl2-dev
            freetype-dev libvorbis-dev openal-soft-dev
        )
    fi
    sudo apk add "${pkgs[@]}"
}

install_suse() {
    echo ">> Installing openSUSE packages..."
    local pkgs=(
        gcc-c++ cmake make
        sqlite3-devel libogg-devel gmp-devel
        libcurl-devel libzstd-devel zlib-devel
        jsoncpp-devel luajit-devel gettext-tools
    )
    if [ "$BUILD_CLIENT" = "TRUE" ]; then
        pkgs+=(
            libpng16-devel libjpeg8-devel Mesa-libGL-devel libSDL2-devel
            freetype2-devel libvorbis-devel openal-soft-devel
        )
    fi
    sudo zypper install -y "${pkgs[@]}"
}

# ── Build ───────────────────────────────────────────────────────────
install_deps

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)

echo ""
echo ">> Configuring with CMake..."
cmake -B build \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
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
