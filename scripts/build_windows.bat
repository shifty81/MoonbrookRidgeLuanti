@echo off
setlocal enabledelayedexpansion

REM ================================================================
REM  MoonBrook Ridge - One-command Windows build
REM
REM  Usage:
REM    scripts\build_windows.bat                  Debug x64 build
REM    scripts\build_windows.bat --release        Release x64 build
REM    scripts\build_windows.bat --help           Show usage
REM
REM  Prerequisites:
REM    - Visual Studio 2022 with "Desktop development with C++"
REM    - Git (to clone vcpkg if needed)
REM
REM  This script will:
REM    1. Check for required tools (cmake, git).
REM    2. Clone and bootstrap vcpkg if VCPKG_ROOT is not set.
REM    3. Configure CMake using the repository presets.
REM    4. Build the project and produce a Visual Studio .sln file.
REM ================================================================

set "PRESET=msvc-x64-debug"
set "BUILD_CONFIG=Debug"

:parse_args
if "%~1"=="" goto :args_done
if /I "%~1"=="--release" (
    set "PRESET=msvc-x64-release"
    set "BUILD_CONFIG=Release"
    shift
    goto :parse_args
)
if /I "%~1"=="--help" goto :show_help
if /I "%~1"=="-h"     goto :show_help
echo Unknown option: %~1
goto :show_help
:args_done

REM ── Locate repo root ──────────────────────────────────────────────
pushd "%~dp0\.."
set "REPO_ROOT=%CD%"
popd

echo ========================================
echo  MoonBrook Ridge - Windows Build
echo ========================================
echo  Preset      : %PRESET%
echo  Config      : %BUILD_CONFIG%
echo  Repo root   : %REPO_ROOT%
echo ========================================

REM ── Check for cmake ───────────────────────────────────────────────
where cmake >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: cmake not found on PATH.
    echo Install Visual Studio 2022 with the "Desktop development with C++"
    echo workload, which bundles CMake, or install CMake manually from
    echo https://cmake.org/download/
    exit /b 1
)

REM ── Check for git ─────────────────────────────────────────────────
where git >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: git not found on PATH.
    echo Install Git from https://git-scm.com/downloads
    exit /b 1
)

REM ── Ensure vcpkg is available ─────────────────────────────────────
if defined VCPKG_ROOT (
    echo.
    echo ^>^> vcpkg found at: %VCPKG_ROOT%
) else (
    echo.
    echo ^>^> VCPKG_ROOT is not set. Setting up vcpkg automatically...

    if not exist "%REPO_ROOT%\vcpkg" (
        echo ^>^> Cloning vcpkg into %REPO_ROOT%\vcpkg ...
        git clone https://github.com/microsoft/vcpkg.git "%REPO_ROOT%\vcpkg"
    )
    if not exist "%REPO_ROOT%\vcpkg\vcpkg.exe" (
        echo ^>^> Bootstrapping vcpkg...
        call "%REPO_ROOT%\vcpkg\bootstrap-vcpkg.bat" -disableMetrics
    )

    set "VCPKG_ROOT=%REPO_ROOT%\vcpkg"
    echo ^>^> Using local vcpkg at: !VCPKG_ROOT!
)

REM ── Configure ─────────────────────────────────────────────────────
echo.
echo ^>^> Running CMake configure (preset: %PRESET%)...
echo    This will also install vcpkg dependencies — first run may take a while.
cmake --preset %PRESET% -S "%REPO_ROOT%"
if errorlevel 1 (
    echo.
    echo ERROR: CMake configure failed. Check the output above for details.
    exit /b 1
)

REM ── Show solution file location ───────────────────────────────────
set "SLN_DIR=%REPO_ROOT%\build\%PRESET%"

echo.
echo ========================================
echo  CMake configure complete!
echo ========================================
echo.
echo  The Visual Studio solution file is at:
echo    %SLN_DIR%\luanti.sln
echo.
echo  You can open it directly:
echo    start "" "%SLN_DIR%\luanti.sln"
echo.

REM ── Build ─────────────────────────────────────────────────────────
echo ^>^> Building (preset: %PRESET%, config: %BUILD_CONFIG%)...
cmake --build --preset %PRESET%
if errorlevel 1 (
    echo.
    echo ERROR: Build failed. Check the output above for details.
    exit /b 1
)

echo.
echo ========================================
echo  Build complete!
echo ========================================
echo.
echo  Binaries are in:
echo    %SLN_DIR%\bin\%BUILD_CONFIG%\
echo.
echo  Solution file (open in Visual Studio):
echo    %SLN_DIR%\luanti.sln
echo.
echo  Quick start:
echo    %SLN_DIR%\bin\%BUILD_CONFIG%\luanti.exe
echo.
echo  Unit tests:
echo    %SLN_DIR%\bin\%BUILD_CONFIG%\luanti.exe --run-unittests
echo ========================================

endlocal
exit /b 0

:show_help
echo.
echo MoonBrook Ridge - Windows build helper
echo.
echo Usage: scripts\build_windows.bat [OPTIONS]
echo.
echo Options:
echo   --release   Build in Release mode (default: Debug)
echo   --help      Show this help message
echo.
echo Prerequisites:
echo   - Visual Studio 2022 with "Desktop development with C++" workload
echo   - Git (https://git-scm.com/downloads)
echo.
echo The script will automatically set up vcpkg if VCPKG_ROOT is not set.
echo After building, it shows the path to the .sln file so you can open
echo it in Visual Studio for debugging and testing.
exit /b 0
