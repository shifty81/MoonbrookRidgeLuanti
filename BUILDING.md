# Building, Launching & Testing MoonBrook Ridge

This guide covers how to **build**, **run**, and **test** MoonBrook Ridge from source.

MoonBrook Ridge is a complete game built on the Luanti engine. When you build it, you're building the entire game - there's no game selection needed.

Pick the path that matches your setup — the **Makefile** or **one-command build
scripts** are the fastest way to get from a fresh clone to a running binary or
Visual Studio solution file.

---

## Table of Contents

0. [Quick Start with Make (recommended)](#0-quick-start-with-make-recommended)
1. [One-Command Build Scripts](#1-one-command-build-scripts)
2. [Quick-Start with Docker (server only)](#2-quick-start-with-docker-server-only)
3. [Native Linux Build (client + server)](#3-native-linux-build-client--server)
4. [Windows Build with Visual Studio](#4-windows-build-with-visual-studio)
5. [Running the Game](#5-running-the-game)
6. [Running Tests](#6-running-tests)
7. [Troubleshooting](#7-troubleshooting)

---

## 0. Quick Start with Make (recommended)

Once you have the dependencies installed (see [Native Linux Build](#3-native-linux-build-client--server)
for your distro, or use `./scripts/build_linux.sh` once to auto-install them),
everything you need is a single `make` command:

```bash
git clone https://github.com/shifty81/MoonbrookRidgeLuanti.git
cd MoonbrookRidgeLuanti
make            # Build debug client + server
```

### Available targets

| Command           | What it does |
|-------------------|--------------|
| `make`            | Build client + server (Debug) |
| `make release`    | Build client + server (Release, optimised) |
| `make server`     | Build dedicated server only (no graphics libs needed) |
| `make test`       | Build and run C++ unit tests |
| `make test-lua`   | Run Lua linting (luacheck) and Busted unit tests |
| `make run`        | Build and launch the game client |
| `make run-server` | Build and launch the dedicated server |
| `make clean`      | Remove the `build/` directory |
| `make help`       | Show all available targets |

After building, binaries are in **`bin/`**:
- `bin/moonbrook_ridge` — graphical client + integrated server
- `bin/moonbrook_ridgeserver` — dedicated headless server

---

## 1. One-Command Build Scripts

The `scripts/` directory contains automation scripts that handle dependency
installation, CMake configuration, and compilation in a single command.

### Linux

```bash
# Clone and build in one shot (Debug, client + server)
git clone https://github.com/shifty81/MoonbrookRidgeLuanti.git
cd MoonbrookRidgeLuanti
./scripts/build_linux.sh
```

The script auto-detects your distribution (Debian/Ubuntu, Fedora, Arch,
Alpine, openSUSE) and installs the required `-dev` packages for you.

| Flag | Purpose |
|------|---------|
| `--release` | Build in Release mode (optimised) |
| `--server-only` | Headless server — skips graphics libraries |
| `--no-install` | Skip automatic package installation |

After the build, binaries are in **`bin/`**.

### Windows

> **Prerequisites:** Visual Studio 2022 with *Desktop development with C++*
> workload, and Git.

```powershell
# PowerShell (recommended)
git clone https://github.com/shifty81/MoonbrookRidgeLuanti.git
cd MoonbrookRidgeLuanti
.\scripts\build_windows.ps1
```

```bat
REM Or classic Command Prompt
scripts\build_windows.bat
```

The script will:

1. **Check** for cmake and git on PATH.
2. **Clone & bootstrap vcpkg** automatically if `VCPKG_ROOT` is not set.
3. **Configure** CMake using the repository presets (installs all C++ deps via vcpkg).
4. **Build** the project and produce a ready-to-open **`.sln` solution file**.

After running the script, look for:

```
build\msvc-x64-debug\moonbrook_ridge.sln     ← open in Visual Studio
build\msvc-x64-debug\bin\Debug\              ← compiled binaries
```

Pass `--release` (bat) or `-Release` (ps1) for an optimised build.

---

## 2. Quick-Start with Docker (server only)

The Docker build produces a **headless server** — perfect for testing game
logic, Lua systems, and multiplayer without needing graphics libraries.

```bash
# Build the server image
docker build -t moonbrook-server .

# Run it (interactive, for quick testing)
docker run --rm -it -p 30000:30000/udp moonbrook-server

# Or run in background
docker run -d --name mbr -p 30000:30000/udp moonbrook-server
```

Connect with the MoonBrook Ridge client to `localhost:30000`.

> **Tip:** Mount a local config to customise the server:
>
> ```bash
> docker run --rm -it \
>   -v $(pwd)/moonbrook_ridge.conf:/etc/moonbrook_ridge/moonbrook_ridge.conf \
>   -p 30000:30000/udp \
>   moonbrook-server
> ```

See also: [Docker server documentation](doc/docker_server.md) and
[Developing with Docker](doc/developing/docker.md).

---

## 3. Native Linux Build (client + server)

A native build gives you the full graphical client with the MoonBrook Ridge
systems loaded as part of the engine builtin.

### 3.1 Install Dependencies

<details>
<summary><strong>Debian / Ubuntu</strong></summary>

```bash
sudo apt install g++ make libc6-dev cmake libpng-dev libjpeg-dev \
  libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev \
  libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev \
  libzstd-dev libluajit-5.1-dev gettext libsdl2-dev
```
</details>

<details>
<summary><strong>Fedora</strong></summary>

```bash
sudo dnf install make automake gcc gcc-c++ kernel-devel cmake libcurl-devel \
  openal-soft-devel libpng-devel libjpeg-devel libvorbis-devel libogg-devel \
  freetype-devel mesa-libGL-devel zlib-devel jsoncpp-devel gmp-devel \
  sqlite-devel luajit-devel leveldb-devel ncurses-devel spatialindex-devel \
  libzstd-devel gettext SDL2-devel
```
</details>

<details>
<summary><strong>Arch</strong></summary>

```bash
sudo pacman -S --needed base-devel libcurl-gnutls cmake libpng libjpeg-turbo \
  sqlite libogg libvorbis openal freetype2 jsoncpp gmp luajit leveldb \
  ncurses zstd gettext sdl2
```
</details>

<details>
<summary><strong>Alpine</strong></summary>

```bash
sudo apk add build-base cmake libpng-dev jpeg-dev mesa-dev sqlite-dev \
  libogg-dev libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev \
  gmp-dev jsoncpp-dev luajit-dev zstd-dev gettext sdl2-dev
```
</details>

For the full dependency list and other platforms, see
[doc/compiling/](doc/compiling/).

### 3.2 Build

```bash
# Configure — RUN_IN_PLACE puts binaries and data in the source tree
cmake . -DRUN_IN_PLACE=TRUE -DCMAKE_BUILD_TYPE=Debug

# Compile (uses all available cores)
make -j$(nproc)
```

This produces `./bin/moonbrook_ridge` (client+server) and `./bin/moonbrook_ridgeserver` (dedicated server).

> **Note:** The binaries are named after the game project. These are the MoonBrook Ridge game executables built on the Luanti engine.

#### Useful CMake flags

| Flag | Purpose |
|------|---------|
| `-DBUILD_SERVER=TRUE` | Also build the standalone server binary |
| `-DBUILD_CLIENT=FALSE` | Skip the graphical client (headless build) |
| `-DBUILD_UNITTESTS=TRUE` | Include C++ unit tests (default: on) |
| `-DCMAKE_BUILD_TYPE=Release` | Optimised release build |

Run `cmake . -LH` to see all available options.

---

## 4. Windows Build with Visual Studio

The repository includes **CMake presets** that automate the entire
configure → build → debug cycle on Windows. Visual Studio 2022 and VS Code
both detect these presets automatically.

### 4.1 Prerequisites

1. **Visual Studio 2022** (Community or higher) with the **Desktop development
   with C++** workload.
2. **vcpkg** — clone and bootstrap it, then set the `VCPKG_ROOT` environment
   variable:

```powershell
git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
cd C:\vcpkg
.\bootstrap-vcpkg.bat
[System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')
```

Restart your terminal or IDE after setting `VCPKG_ROOT`.

### 4.2 Build with Visual Studio 2022

1. Open Visual Studio → **File → Open → Folder…** → select this repo.
2. Visual Studio detects `CMakePresets.json` and shows available presets in the
   toolbar.
3. Select **MSVC x64 Debug** (or another preset) from the configuration
   dropdown.
4. Press **Ctrl+Shift+B** to build.
5. Press **F5** to launch the client under the debugger.

### 4.3 Build with VS Code

1. Install the **C/C++ Extension Pack** extension.
2. Open the repository folder. CMake Tools picks up the presets automatically.
3. Select a configure preset from the status bar.
4. Use the included `tasks.json` / `launch.json`:
   - **Ctrl+Shift+B** → Build Debug
   - **F5** → Launch Client (Debug) with breakpoints

### 4.4 Build from the command line (PowerShell)

```powershell
cmake --preset msvc-x64-debug
cmake --build --preset msvc-x64-debug
.\build\msvc-x64-debug\bin\Debug\moonbrook_ridge.exe --run-unittests
```

For full details and additional presets, see
[doc/compiling/windows.md](doc/compiling/windows.md).

---

## 5. Running the Game

### 5.1 Singleplayer (graphical client)

```bash
./bin/moonbrook_ridge
```

This opens the MoonBrook Ridge main menu.  MoonBrook Ridge systems
(time, survival, weather, NPCs, crafting, loot) are loaded automatically
through the engine `builtin/game/init.lua`.

### 5.2 Dedicated Server

```bash
# Start a server
./bin/moonbrook_ridgeserver --worldname test_world

# Or with a custom config file
./bin/moonbrook_ridgeserver --config moonbrook_ridge.conf
```

Connect with a MoonBrook Ridge client to `localhost:30000`.

### 5.3 Verifying MBR Systems Are Loaded

Once in-game, you can verify the MoonBrook Ridge systems with these chat
commands:

| Command | System Tested |
|---------|---------------|
| `/time` | Confirm time of day responds |
| `/craft` | Opens the quality-based crafting station |
| `/npc_status` | Shows NPC relationship levels |
| `/family` | Opens the family/marriage menu |
| `/iteminfo` | Inspects loot stats on the held item |

The HUD should display: season/day/year clock (top-center), weather indicator
(top-right), and hunger/thirst bars (bottom).

---

## 6. Running Tests

### 6.1 Lua Linting (Luacheck)

Luacheck validates all Lua code for errors, undefined globals, and style
issues.

```bash
# Install luacheck (requires LuaRocks)
luarocks install --local luacheck

# Lint builtin code (includes MBR systems)
~/.luarocks/bin/luacheck builtin

# Lint game mods
~/.luarocks/bin/luacheck --config=games/moonbrook_ridge/.luacheckrc games/moonbrook_ridge
```

### 6.2 Lua Unit Tests (Busted)

Busted tests validate pure Lua logic without needing the full engine.  Tests
live alongside the code they exercise:

- `builtin/common/tests/` — engine utility tests (vectors, serialisation, etc.)
- `builtin/game/tests/` — MBR system tests (time, loot, crafting)

```bash
# Install busted (requires LuaRocks)
luarocks install --local busted

# Run all builtin tests
~/.luarocks/bin/busted builtin

# Run with LuaJIT (if installed)
~/.luarocks/bin/busted builtin --lua=$HOME/LuaJIT/src/luajit

# Run only MBR-specific tests
~/.luarocks/bin/busted builtin/game/tests/
```

### 6.3 C++ Unit Tests

The engine includes C++ unit tests that are compiled when
`BUILD_UNITTESTS=TRUE` (the default).

```bash
# After building:
./bin/moonbrook_ridge --run-unittests
```

### 6.4 Integration Tests (Multiplayer)

These spin up a server and client to test game features end-to-end.
Requires a graphical environment (or `xvfb-run`).

```bash
# Multiplayer test
./util/test_multiplayer.sh

# Singleplayer visual test (requires X or Wayland)
xvfb-run ./util/test_singleplayer.sh
```

### 6.5 CI Pipeline

GitHub Actions automatically runs all of the above on every push and PR.  The
workflows are in `.github/workflows/`:

| Workflow | What It Tests |
|----------|--------------|
| `lua.yml` | Luacheck lint + Busted unit tests + integration tests |
| `linux.yml` | C++ build + unit tests (GCC 9/14, Clang 11/20) |
| `docker_image.yml` | Docker image build + smoke test |
| `cpp_lint.yml` | C++ code style (clang-tidy) |
| `windows.yml` | Windows cross-compile |
| `macos.yml` | macOS build |

---

## 7. Troubleshooting

### Missing dependencies

If `cmake` fails with "Could NOT find …", install the corresponding `-dev`
package for your distribution.  The most common missing packages are:

- `libsdl2-dev` — required for the graphical client
- `libluajit-5.1-dev` — optional but strongly recommended
- `libfreetype6-dev` — required for font rendering

### Server-only build (no graphics)

If you don't need the client UI:

```bash
cmake . -DBUILD_CLIENT=FALSE -DBUILD_SERVER=TRUE -DRUN_IN_PLACE=TRUE
make -j$(nproc)
./bin/moonbrook_ridgeserver
```

### Luacheck errors on MBR files

MBR systems use the global `mbr` table and the `core` engine API.  These are
declared in `.luacheckrc`.  If you add new MBR globals, register them there.

### Docker build fails

Make sure Docker BuildKit is enabled (`DOCKER_BUILDKIT=1`) and you have at
least 4 GB of free disk space for the multi-stage build.

### Running on WSL2 (Windows)

For the graphical client on WSL2, install an X server (e.g. VcXsrv or the
built-in WSLg in Windows 11).  The server-only build works without any
graphics setup.