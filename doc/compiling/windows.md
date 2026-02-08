# Compiling on Windows using MSVC

## Requirements

- [Visual Studio 2022](https://visualstudio.microsoft.com) (Community edition or higher)
- [CMake 3.21+](https://cmake.org/download/) (bundled with Visual Studio 2022)
- [vcpkg](https://github.com/Microsoft/vcpkg)
- [Git](https://git-scm.com/downloads)

## Initial Setup

### 1. Install vcpkg

```powershell
git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
cd C:\vcpkg
.\bootstrap-vcpkg.bat
```

Set the `VCPKG_ROOT` environment variable so CMake presets can find it:

```powershell
[System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')
```

Restart your terminal or IDE after setting the variable.

### 2. Install dependencies

The repository includes a `vcpkg.json` manifest that automatically installs
dependencies during the CMake configure step. No manual `vcpkg install` is
needed when using the presets below.

If you prefer to install packages manually:

```powershell
vcpkg install zlib zstd curl[ssl] openal-soft libvorbis libogg libjpeg-turbo sqlite3 freetype luajit gmp jsoncpp gettext[tools] sdl2 --triplet x64-windows
```

- `curl[ssl]` is optional, but required to use many online features.
- `openal-soft`, `libvorbis` and `libogg` are optional, but required to use sound.
- `luajit` is optional, it replaces the integrated Lua interpreter with a faster just-in-time interpreter.
- `gmp` and `jsoncpp` are optional, otherwise the bundled versions will be compiled.
- `gettext` is optional, but required to use translations.

## Compile with CMake Presets (recommended)

The repository ships `CMakePresets.json` with ready-to-use presets for
Visual Studio. This is the easiest way to build and debug.

### a) Visual Studio 2022 ("Open Folder" / CMake mode)

1. Open Visual Studio 2022.
2. Choose **File → Open → Folder…** and select the repository root.
3. Visual Studio detects `CMakePresets.json` automatically.
4. In the toolbar, select a configure preset from the dropdown:
   - **MSVC x64 Debug** — for everyday development and debugging.
   - **MSVC x64 Release** — for optimised builds.
   - **MSVC x64 RelWithDebInfo** — release speed with debugger support.
5. Visual Studio runs CMake configure + vcpkg dependency install automatically.
6. Press **Ctrl+Shift+B** (or **Build → Build All**) to compile.
7. Press **F5** to launch the client under the debugger.

> **Tip:** Set breakpoints in any `.cpp` file, and the debugger will stop
> there. Use **Debug → Windows → Call Stack** and **Watch** to inspect state.

### b) VS Code with CMake Tools extension

1. Install the **C/C++ Extension Pack** (`ms-vscode.cpptools-extension-pack`)
   and **CMake Tools** (`ms-vscode.cmake-tools`).
2. Open the repository folder in VS Code.
3. CMake Tools detects the presets automatically. Select a configure preset
   from the status bar or the Command Palette (`Ctrl+Shift+P` →
   **CMake: Select Configure Preset**).
4. The included `tasks.json` and `launch.json` provide:
   - **Build Debug** / **Build Release** tasks (Ctrl+Shift+B).
   - **Launch Client (Debug)** — start the game with the debugger.
   - **Launch Server (Debug)** — start a dedicated server with DevTest.
   - **Run Unit Tests (Debug)** — build and run C++ unit tests.

### c) Command-line (PowerShell)

```powershell
# Configure (uses Visual Studio 17 2022 generator + vcpkg)
cmake --preset msvc-x64-debug

# Build
cmake --build --preset msvc-x64-debug

# Run unit tests
.\build\msvc-x64-debug\bin\Debug\luanti.exe --run-unittests
```

Replace `msvc-x64-debug` with `msvc-x64-release` or `msvc-x64-relwithdebinfo`
for other configurations.

### Available presets

| Configure Preset          | Arch | Config         |
|---------------------------|------|----------------|
| `msvc-x64-debug`          | x64  | Debug          |
| `msvc-x64-release`        | x64  | Release        |
| `msvc-x64-relwithdebinfo` | x64  | RelWithDebInfo |
| `msvc-x86-debug`          | x86  | Debug          |
| `msvc-x86-release`        | x86  | Release        |

Build presets share the same names and are paired to their configure preset.

## Legacy: CMake GUI workflow

If you prefer the traditional CMake GUI approach:

1. Start up the CMake GUI.
2. Select **Browse Source...** and select the repository root.
3. Select **Browse Build...** and select a build directory (e.g. `luanti-build`).
4. Select **Configure**.
5. Choose the right Visual Studio version and target platform.
6. Choose **Specify toolchain file for cross-compiling**.
7. Click **Next**.
8. Select the vcpkg toolchain file e.g. `C:\vcpkg\scripts\buildsystems\vcpkg.cmake`.
9. Click **Finish**.
10. Wait until CMake has generated the cache file.
11. If there are any errors, solve them and hit **Configure**.
12. Click **Generate**.
13. Click **Open Project**.
14. Compile inside Visual Studio.


## Windows Installer using WiX Toolset

Requirements:
* [Visual Studio 2017 or newer](https://visualstudio.microsoft.com/)
* [WiX Toolset](https://wixtoolset.org/)

In the Visual Studio Installer select **Optional Features → WiX Toolset**.

Build the binaries as described above, but make sure you unselect `RUN_IN_PLACE`.

Open the generated project file with Visual Studio. Right-click **Package** and choose **Generate**.
It may take some minutes to generate the installer.
