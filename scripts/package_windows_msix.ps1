param(
  [switch]$SkipPrereqCheck
)

$ErrorActionPreference = "Stop"

if (-not $SkipPrereqCheck) {
  & powershell -ExecutionPolicy Bypass -File "scripts/setup_windows_build.ps1" -InstallHints
}

flutter pub get

if (-not (Select-String -Path "pubspec.yaml" -Pattern "msix:" -Quiet)) {
  throw "msix dependency not found in pubspec.yaml. Add package 'msix' before running this script."
}

dart run msix:create
Write-Host "MSIX package build completed." -ForegroundColor Green
