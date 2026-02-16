param(
  [switch]$SkipPrereqCheck
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command iscc -ErrorAction SilentlyContinue)) {
  throw "Inno Setup Compiler (iscc) not found in PATH."
}

if (-not $SkipPrereqCheck) {
  & powershell -ExecutionPolicy Bypass -File "scripts/setup_windows_build.ps1" -InstallHints
}

flutter pub get
flutter build windows --release

if (-not (Test-Path "installer/XtractAid.iss")) {
  throw "Missing installer script: installer/XtractAid.iss"
}

iscc "installer/XtractAid.iss"
Write-Host "Inno Setup package build completed." -ForegroundColor Green
