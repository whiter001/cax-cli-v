# CAX Format Script
# Run with: .\scripts\fmt.ps1

param(
    [switch]$Check,
    [switch]$Verbose
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$SrcDir = Join-Path $ProjectRoot "src"
$TestsDir = Join-Path $ProjectRoot "tests"

Write-Host "CAX Format Script" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host ""

# Check V installation
Write-Host "Checking V installation..." -ForegroundColor Yellow
$vVersion = v version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: V language is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "  V version: $vVersion" -ForegroundColor Green
Write-Host ""

# Format source files
Write-Host "Formatting source files..." -ForegroundColor Yellow
$sourceFiles = Get-ChildItem -Path $SrcDir -Filter "*.v"
$formattedCount = 0
$errorCount = 0

foreach ($file in $sourceFiles) {
    if ($Verbose) {
        Write-Host "  Formatting: $($file.Name)" -ForegroundColor Gray
    }
    
    if ($Check) {
        # Check only
        $output = v fmt $file.FullName 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Error: $($file.Name)" -ForegroundColor Red
            $errorCount++
        } else {
            Write-Host "  OK: $($file.Name)" -ForegroundColor Green
            $formattedCount++
        }
    } else {
        # Format in place
        v fmt -w $file.FullName 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            if ($Verbose) {
                Write-Host "  Formatted: $($file.Name)" -ForegroundColor Green
            }
            $formattedCount++
        } else {
            Write-Host "  Error: $($file.Name)" -ForegroundColor Red
            $errorCount++
        }
    }
}

Write-Host ""

# Format test files
Write-Host "Formatting test files..." -ForegroundColor Yellow
$testFiles = Get-ChildItem -Path $TestsDir -Filter "*.v"

foreach ($file in $testFiles) {
    if ($Verbose) {
        Write-Host "  Formatting: $($file.Name)" -ForegroundColor Gray
    }
    
    if ($Check) {
        $output = v fmt $file.FullName 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Error: $($file.Name)" -ForegroundColor Red
            $errorCount++
        } else {
            Write-Host "  OK: $($file.Name)" -ForegroundColor Green
            $formattedCount++
        }
    } else {
        v fmt -w $file.FullName 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            if ($Verbose) {
                Write-Host "  Formatted: $($file.Name)" -ForegroundColor Green
            }
            $formattedCount++
        } else {
            Write-Host "  Error: $($file.Name)" -ForegroundColor Red
            $errorCount++
        }
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Formatted: $formattedCount files" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Errors: $errorCount files" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  Errors: 0" -ForegroundColor Green
    Write-Host ""
    Write-Host "All files formatted successfully!" -ForegroundColor Green
}
