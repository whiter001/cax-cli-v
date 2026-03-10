# CAX Test Runner Script
# Run with: .\scripts\test.ps1

param(
    [string]$TestName,
    [switch]$Verbose,
    [switch]$All
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$TestsDir = Join-Path $ProjectRoot "tests"

Write-Host "CAX Test Runner" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
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

# Test files
$testFiles = @(
    @{ Name = "Unit Tests"; File = "test_cax.v" },
    @{ Name = "OSD Tests"; File = "test_osdtext.v" },
    @{ Name = "Exec Tests"; File = "test_exec.v" }
)

$passed = 0
$failed = 0
$total = 0

if ($TestName) {
    # Run specific test
    $test = $testFiles | Where-Object { $_.Name -like "*$TestName*" }
    if ($test) {
        Write-Host "Running: $($test.Name)" -ForegroundColor Cyan
        Write-Host ""
        v run (Join-Path $TestsDir $test.File)
        if ($LASTEXITCODE -eq 0) {
            $passed++
        } else {
            $failed++
        }
        $total++
    } else {
        Write-Host "Test not found: $TestName" -ForegroundColor Red
        Write-Host "Available tests:" -ForegroundColor Yellow
        foreach ($t in $testFiles) {
            Write-Host "  $($t.Name)" -ForegroundColor Gray
        }
        exit 1
    }
} else {
    # Run all tests
    Write-Host "Running all tests..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($test in $testFiles) {
        Write-Host "[$($test.Name)]" -ForegroundColor Yellow
        v run (Join-Path $TestsDir $test.File)
        
        if ($LASTEXITCODE -eq 0) {
            $passed++
            Write-Host "  PASS" -ForegroundColor Green
        } else {
            $failed++
            Write-Host "  FAIL" -ForegroundColor Red
        }
        $total++
        Write-Host ""
    }
}

# Summary
Write-Host "================" -ForegroundColor Cyan
Write-Host "Test Summary:" -ForegroundColor Cyan
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  Total:  $total" -ForegroundColor Cyan
Write-Host ""

if ($failed -gt 0) {
    Write-Host "Some tests failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed!" -ForegroundColor Green
}
