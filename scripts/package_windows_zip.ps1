param(
  [switch]$SkipPrereqCheck
)

$ErrorActionPreference = "Stop"

if (-not $SkipPrereqCheck) {
  & powershell -ExecutionPolicy Bypass -File "scripts/setup_windows_build.ps1" -InstallHints
}

$iconPath = "windows/runner/resources/app_icon.ico"
if (-not (Test-Path $iconPath)) {
  throw "Missing app icon: $iconPath"
}

flutter pub get
flutter build windows --release

$releaseDir = "build/windows/x64/runner/Release"
if (-not (Test-Path $releaseDir)) {
  throw "Release directory not found: $releaseDir"
}

$distDir = "dist"
if (-not (Test-Path $distDir)) {
  New-Item -ItemType Directory -Path $distDir | Out-Null
}

$zipPath = Join-Path $distDir "XtractAid-Windows.zip"
if (Test-Path $zipPath) {
  Remove-Item $zipPath -Force
}

Compress-Archive -Path "$releaseDir/*" -DestinationPath $zipPath -Force
Write-Host "Created ZIP package: $zipPath" -ForegroundColor Green
