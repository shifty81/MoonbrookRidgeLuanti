# Building, Launching & Testing MoonBrook Ridge

This guide covers how to **build**, **run**, and **test** MoonBrook Ridge from source.

MoonBrook Ridge is a complete game built on the Luanti engine. When you build it, you're building the entire game - there's no game selection needed.

Pick the path that matches your setup — Docker is the fastest way to get a running server, while a native build gives you the full client with graphics.

---

## Table of Contents

1. [Quick-Start with Docker (server only)](#1-quick-start-with-docker-server-only)
2. [Native Linux Build (client + server)](#2-native-linux-build-client--server)
3. [Windows Build with Visual Studio](#3-windows-build-with-visual-studio)
4. [Running the Game](#4-running-the-game)
5. [Running Tests](#5-running-tests)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Quick-Start with Docker (server only)

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

Connect with any Luanti client to `localhost:30000`.

> **Tip:** Mount a local config to customise the server:
>
> ```bash
> docker run --rm -it \
>   -v $(pwd)/minetest.conf.example:/etc/minetest/minetest.conf \
>   -p 30000:30000/udp \
>   moonbrook-server
> ```

See also: [Docker server documentation](doc/docker_server.md) and
[Developing with Docker](doc/developing/docker.md).

---

## 2. Native Linux Build (client + server)

A native build gives you the full graphical client with the MoonBrook Ridge
systems loaded as part of the engine builtin.

### 2.1 Install Dependencies

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

### 2.2 Build

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
| `-DINSTALL_DEVTEST=TRUE` | Ship the DevTest game alongside the binary |

Run `cmake . -LH` to see all available options.

---

## 3. Windows Build with Visual Studio

The repository includes **CMake presets** that automate the entire
configure → build → debug cycle on Windows. Visual Studio 2022 and VS Code
both detect these presets automatically.

### 3.1 Prerequisites

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

### 3.2 Build with Visual Studio 2022

1. Open Visual Studio → **File → Open → Folder…** → select this repo.
2. Visual Studio detects `CMakePresets.json` and shows available presets in the
   toolbar.
3. Select **MSVC x64 Debug** (or another preset) from the configuration
   dropdown.
4. Press **Ctrl+Shift+B** to build.
5. Press **F5** to launch the client under the debugger.

### 3.3 Build with VS Code

1. Install the **C/C++ Extension Pack** extension.
2. Open the repository folder. CMake Tools picks up the presets automatically.
3. Select a configure preset from the status bar.
4. Use the included `tasks.json` / `launch.json`:
   - **Ctrl+Shift+B** → Build Debug
   - **F5** → Launch Client (Debug) with breakpoints

### 3.4 Build from the command line (PowerShell)

```powershell
cmake --preset msvc-x64-debug
cmake --build --preset msvc-x64-debug
.\build\msvc-x64-debug\bin\Debug\luanti.exe --run-unittests
```

For full details and additional presets, see
[doc/compiling/windows.md](doc/compiling/windows.md).

---

## 4. Running the Game

### 4.1 Singleplayer (graphical client)

```bash
./bin/luanti
```

This opens the Luanti main menu.  Select a game — MoonBrook Ridge systems
(time, survival, weather, NPCs, crafting, loot) are loaded automatically
through the engine `builtin/game/init.lua`.  You can use **DevTest** as a
sandbox world that includes basic nodes and tools.

### 4.2 Dedicated Server

```bash
# Start a server using the DevTest game
./bin/luantiserver --gameid devtest --worldname test_world

# Or with a custom config file
./bin/luantiserver --config minetest.conf.example
```

Connect with a Luanti client to `localhost:30000`.

### 4.3 Verifying MBR Systems Are Loaded

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

## 5. Running Tests

### 5.1 Lua Linting (Luacheck)

Luacheck validates all Lua code for errors, undefined globals, and style
issues.

```bash
# Install luacheck (requires LuaRocks)
luarocks install --local luacheck

# Lint builtin code (includes MBR systems)
~/.luarocks/bin/luacheck builtin

# Lint DevTest mods
~/.luarocks/bin/luacheck --config=games/devtest/.luacheckrc games/devtest
```

### 5.2 Lua Unit Tests (Busted)

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

### 5.3 C++ Unit Tests

The engine includes C++ unit tests that are compiled when
`BUILD_UNITTESTS=TRUE` (the default).

```bash
# After building:
./bin/luanti --run-unittests
```

### 5.4 Integration Tests (Multiplayer)

These spin up a server and client to test game features end-to-end.
Requires a graphical environment (or `xvfb-run`).

```bash
# Multiplayer test with DevTest
./util/test_multiplayer.sh

# Singleplayer visual test (requires X or Wayland)
xvfb-run ./util/test_singleplayer.sh
```

### 5.5 CI Pipeline

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

## 6. Troubleshooting

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
./bin/luantiserver --gameid devtest
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
