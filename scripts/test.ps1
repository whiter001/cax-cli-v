# ============================================================================
# CAX 测试运行器 - PowerShell 版本
# ============================================================================
# 功能：运行 CAX 项目的所有测试
# 用法：
#   .\scripts\test.ps1                 # 运行所有测试
#   .\scripts\test.ps1 OSD             # 运行包含"OSD"的测试
#   .\scripts\test.ps1 -Verbose        # 显示详细信息
# 参数：
#   TestName - 测试名称（模糊匹配）
#   Verbose - 显示详细信息
#   All - 强制运行所有测试
# ============================================================================

param(
    [string]$TestName,     # 测试名称（可选，用于运行特定测试）
    [switch]$Verbose,      # 详细模式开关
    [switch]$All           # 运行所有测试开关
)

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# 获取项目根目录
$ProjectRoot = Split-Path -Parent $ScriptDir
# 测试文件目录
$TestsDir = Join-Path $ProjectRoot "tests"

# 显示标题
Write-Host "CAX Test Runner" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 检查 V 语言环境
# ============================================================================

Write-Host "Checking V installation..." -ForegroundColor Yellow

# 获取 V 版本
$vVersion = v version 2>&1

# 检查 V 是否安装
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: V language is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "  V version: $vVersion" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 定义测试文件列表
# ============================================================================

$testFiles = @(
    @{ Name = "Unit Tests"; File = "test_cax.v"; Description = "单元测试：基础功能测试" },
    @{ Name = "OSD Tests"; File = "test_osdtext.v"; Description = "OSD 功能专项测试" },
    @{ Name = "Exec Tests"; File = "test_exec.v"; Description = "执行测试：交互式命令测试" }
)

# 计数器
$passed = 0
$failed = 0
$total = 0

# ============================================================================
# 运行测试
# ============================================================================

if ($TestName) {
    # 运行特定测试
    $test = $testFiles | Where-Object { $_.Name -like "*$TestName*" }
    
    if ($test) {
        Write-Host "Running: $($test.Name)" -ForegroundColor Cyan
        Write-Host "  $($test.Description)" -ForegroundColor Gray
        Write-Host ""
        
        # 运行测试文件
        v run (Join-Path $TestsDir $test.File)
        
        # 记录结果
        if ($LASTEXITCODE -eq 0) {
            $passed++
        } else {
            $failed++
        }
        $total++
    } else {
        # 未找到匹配的测试
        Write-Host "Test not found: $TestName" -ForegroundColor Red
        Write-Host "Available tests:" -ForegroundColor Yellow
        
        foreach ($t in $testFiles) {
            Write-Host "  $($t.Name) - $($t.Description)" -ForegroundColor Gray
        }
        
        exit 1
    }
} else {
    # 运行所有测试
    Write-Host "Running all tests..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($test in $testFiles) {
        # 显示测试名称
        Write-Host "[$($test.Name)]" -ForegroundColor Yellow
        Write-Host "  $($test.Description)" -ForegroundColor Gray
        
        # 运行测试
        v run (Join-Path $TestsDir $test.File)
        
        # 记录结果
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

# ============================================================================
# 显示测试摘要
# ============================================================================

Write-Host "================" -ForegroundColor Cyan
Write-Host "Test Summary:" -ForegroundColor Cyan
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  Total:  $total" -ForegroundColor Cyan
Write-Host ""

# 根据结果设置退出码
if ($failed -gt 0) {
    Write-Host "Some tests failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed!" -ForegroundColor Green
}

# 脚本结束
