# CAX Build Script
# Run with: .\scripts\build.ps1

param(
    [string]$Output = "cax.exe",
    [switch]$Release,
    [switch]$Clean
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$SrcDir = Join-Path $ProjectRoot "src"
$OutputPath = Join-Path $ProjectRoot $Output

Write-Host "CAX Build Script" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning..." -ForegroundColor Yellow
    if (Test-Path $OutputPath) {
        Remove-Item $OutputPath -Force
        Write-Host "  Removed: $OutputPath" -ForegroundColor Gray
    }
    Write-Host ""
}

# Check V installation
Write-Host "Checking V installation..." -ForegroundColor Yellow
$vVersion = v version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: V language is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Download from: https://vlang.io" -ForegroundColor Gray
    exit 1
}
Write-Host "  V version: $vVersion" -ForegroundColor Green
Write-Host ""

# Build
Write-Host "Building CAX..." -ForegroundColor Yellow

if ($Release) {
    Write-Host "  Mode: Release (optimized)" -ForegroundColor Gray
    v -prod -o $OutputPath $SrcDir\cax_simple.v
} else {
    Write-Host "  Mode: Debug" -ForegroundColor Gray
    v -o $OutputPath $SrcDir\cax_simple.v
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "  Output: $OutputPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Run with: .\$Output /HELP" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
