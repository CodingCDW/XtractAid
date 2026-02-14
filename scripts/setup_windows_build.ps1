param(
  [switch]$InstallHints
)

$ErrorActionPreference = "Stop"

function Write-Ok($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERR] $msg" -ForegroundColor Red }

function Test-Command($name) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  return $null -ne $cmd
}

function Print-InstallHints {
  Write-Host ""
  Write-Host "Install-Hinweise (manuell ausfuehren):" -ForegroundColor Cyan
  Write-Host "1) Rust (MSVC):"
  Write-Host "   - rustup-init von https://rustup.rs installieren"
  Write-Host "   - danach: rustup default stable-x86_64-pc-windows-msvc"
  Write-Host ""
  Write-Host "2) LLVM/Clang:"
  Write-Host "   - z.B. choco install llvm"
  Write-Host "   - danach LIBCLANG_PATH setzen, z.B.:"
  Write-Host "     setx LIBCLANG_PATH `"C:\Program Files\LLVM\bin`""
  Write-Host ""
  Write-Host "3) Visual Studio Build Tools:"
  Write-Host "   - Workload: Desktopentwicklung mit C++"
  Write-Host "   - Komponenten: MSVC, CMake Tools, Windows SDK"
}

Write-Host "== Windows Build Prereq Check (Flutter + Rust OCR) ==" -ForegroundColor Cyan

$missing = @()

if (Test-Command "rustup") {
  $rustupVer = rustup --version 2>$null
  Write-Ok "rustup gefunden: $rustupVer"
} else {
  Write-Err "rustup nicht gefunden."
  $missing += "rustup"
}

if (Test-Command "rustc") {
  $rustcVer = rustc --version 2>$null
  Write-Ok "rustc gefunden: $rustcVer"
} else {
  Write-Err "rustc nicht gefunden."
  $missing += "rustc"
}

if (Test-Command "cargo") {
  $cargoVer = cargo --version 2>$null
  Write-Ok "cargo gefunden: $cargoVer"
} else {
  Write-Err "cargo nicht gefunden."
  $missing += "cargo"
}

if (Test-Command "rustup") {
  $activeToolchain = rustup show active-toolchain 2>$null
  if ($activeToolchain -match "x86_64-pc-windows-msvc") {
    Write-Ok "Rust Toolchain ist MSVC: $activeToolchain"
  } else {
    Write-Warn "Aktive Rust Toolchain ist nicht eindeutig MSVC: $activeToolchain"
  }
}

if (Test-Command "clang") {
  $clangVer = clang --version 2>$null | Select-Object -First 1
  Write-Ok "clang gefunden: $clangVer"
} else {
  Write-Warn "clang nicht gefunden (kann fuer bindgen/libclang erforderlich sein)."
}

if ($env:LIBCLANG_PATH) {
  if (Test-Path $env:LIBCLANG_PATH) {
    Write-Ok "LIBCLANG_PATH gesetzt: $env:LIBCLANG_PATH"
  } else {
    Write-Warn "LIBCLANG_PATH gesetzt, aber Pfad existiert nicht: $env:LIBCLANG_PATH"
  }
} else {
  Write-Warn "LIBCLANG_PATH nicht gesetzt."
}

if (Test-Command "cl") {
  Write-Ok "MSVC cl.exe gefunden."
} else {
  Write-Warn "cl.exe nicht im aktuellen PATH (VS Build Tools Umgebung evtl. nicht aktiv)."
}

if (Test-Command "cmake") {
  $cmakeVer = cmake --version 2>$null | Select-Object -First 1
  Write-Ok "cmake gefunden: $cmakeVer"
} else {
  Write-Warn "cmake nicht gefunden."
}

if (Test-Command "flutter") {
  $flutterVer = flutter --version 2>$null | Select-Object -First 1
  Write-Ok "flutter gefunden: $flutterVer"
} else {
  Write-Warn "flutter nicht gefunden."
}

Write-Host ""
if ($missing.Count -eq 0) {
  Write-Ok "Basisvoraussetzungen fuer Rust-Plugins sind vorhanden."
  exit 0
}

Write-Err "Fehlende Pflichttools: $($missing -join ', ')"
if ($InstallHints) {
  Print-InstallHints
}
exit 1
