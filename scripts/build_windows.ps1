#Requires -Version 5.1
<#
.SYNOPSIS
    MoonBrook Ridge — One-command Windows build (PowerShell).

.DESCRIPTION
    Checks prerequisites, sets up vcpkg if needed, configures CMake with
    the repository presets, builds the project, and tells you where to find
    the .sln file and the compiled binaries.

.PARAMETER Release
    Build in Release mode instead of the default Debug.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\scripts\build_windows.ps1                 # Debug x64 build
    .\scripts\build_windows.ps1 -Release        # Release x64 build
#>
[CmdletBinding()]
param(
    [switch]$Release,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Help ────────────────────────────────────────────────────────────
if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ── Configuration ───────────────────────────────────────────────────
if ($Release) {
    $Preset      = 'msvc-x64-release'
    $BuildConfig = 'Release'
} else {
    $Preset      = 'msvc-x64-debug'
    $BuildConfig = 'Debug'
}

$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' MoonBrook Ridge — Windows Build'        -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host " Preset      : $Preset"
Write-Host " Config      : $BuildConfig"
Write-Host " Repo root   : $RepoRoot"
Write-Host '========================================' -ForegroundColor Cyan

# ── Check prerequisites ────────────────────────────────────────────
function Test-Command([string]$Name) {
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command 'cmake')) {
    Write-Host ''
    Write-Host 'ERROR: cmake not found on PATH.' -ForegroundColor Red
    Write-Host 'Install Visual Studio 2022 with the "Desktop development with C++"'
    Write-Host 'workload (bundles CMake), or install CMake from https://cmake.org/download/'
    exit 1
}

if (-not (Test-Command 'git')) {
    Write-Host ''
    Write-Host 'ERROR: git not found on PATH.' -ForegroundColor Red
    Write-Host 'Install Git from https://git-scm.com/downloads'
    exit 1
}

# ── Ensure vcpkg is available ──────────────────────────────────────
if ($env:VCPKG_ROOT) {
    Write-Host ''
    Write-Host ">> vcpkg found at: $env:VCPKG_ROOT"
} else {
    Write-Host ''
    Write-Host '>> VCPKG_ROOT is not set. Setting up vcpkg automatically...'

    $VcpkgDir = Join-Path $RepoRoot 'vcpkg'

    if (-not (Test-Path $VcpkgDir)) {
        Write-Host ">> Cloning vcpkg into $VcpkgDir ..."
        & git clone https://github.com/microsoft/vcpkg.git $VcpkgDir
        if ($LASTEXITCODE -ne 0) { exit 1 }
    }

    $VcpkgExe = Join-Path $VcpkgDir 'vcpkg.exe'
    if (-not (Test-Path $VcpkgExe)) {
        Write-Host '>> Bootstrapping vcpkg...'
        & (Join-Path $VcpkgDir 'bootstrap-vcpkg.bat') -disableMetrics
        if ($LASTEXITCODE -ne 0) { exit 1 }
    }

    $env:VCPKG_ROOT = $VcpkgDir
    Write-Host ">> Using local vcpkg at: $env:VCPKG_ROOT"
}

# ── CMake configure ────────────────────────────────────────────────
Write-Host ''
Write-Host ">> Running CMake configure (preset: $Preset)..."
Write-Host '   This will also install vcpkg dependencies — first run may take a while.'
& cmake --preset $Preset -S $RepoRoot
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host 'ERROR: CMake configure failed. Check the output above.' -ForegroundColor Red
    exit 1
}

$SlnDir  = Join-Path $RepoRoot "build\$Preset"
$SlnFile = Join-Path $SlnDir   'luanti.sln'

Write-Host ''
Write-Host '========================================' -ForegroundColor Green
Write-Host ' CMake configure complete!'               -ForegroundColor Green
Write-Host '========================================' -ForegroundColor Green
Write-Host ''
Write-Host ' The Visual Studio solution file is at:'
Write-Host "   $SlnFile" -ForegroundColor Yellow
Write-Host ''
Write-Host ' You can open it with:'
Write-Host "   Start-Process '$SlnFile'"
Write-Host ''

# ── Build ───────────────────────────────────────────────────────────
Write-Host ">> Building (preset: $Preset, config: $BuildConfig)..."
& cmake --build --preset $Preset
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host 'ERROR: Build failed. Check the output above.' -ForegroundColor Red
    exit 1
}

$BinDir = Join-Path $SlnDir "bin\$BuildConfig"

Write-Host ''
Write-Host '========================================' -ForegroundColor Green
Write-Host ' Build complete!'                         -ForegroundColor Green
Write-Host '========================================' -ForegroundColor Green
Write-Host ''
Write-Host ' Binaries are in:'
Write-Host "   $BinDir" -ForegroundColor Yellow
Write-Host ''
Write-Host ' Solution file (open in Visual Studio):'
Write-Host "   $SlnFile" -ForegroundColor Yellow
Write-Host ''
Write-Host ' Quick start:'
Write-Host "   & '$BinDir\luanti.exe'"
Write-Host ''
Write-Host ' Unit tests:'
Write-Host "   & '$BinDir\luanti.exe' --run-unittests"
Write-Host '========================================' -ForegroundColor Green
