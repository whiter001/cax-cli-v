# ============================================================================
# CAX 构建脚本 - PowerShell 版本
# ============================================================================
# 功能：编译 CAX V 语言源代码为可执行文件
# 用法：
#   .\scripts\build.ps1                    # Debug 构建
#   .\scripts\build.ps1 -Release           # Release 构建（优化）
#   .\scripts\build.ps1 -Clean             # 清理后构建
#   .\scripts\build.ps1 -Output cax.exe    # 指定输出文件名
# 参数：
#   Output - 输出文件名（默认：cax.exe）
#   Release - 使用发布模式（启用优化）
#   Clean - 构建前清理旧文件
# ============================================================================

param(
    [string]$Output = "cax.exe",   # 输出文件名
    [switch]$Release,              # 发布模式开关
    [switch]$Clean                 # 清理开关
)

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# 获取项目根目录
$ProjectRoot = Split-Path -Parent $ScriptDir
# 源代码目录
$SrcDir = Join-Path $ProjectRoot "src"
# 输出文件完整路径
$OutputPath = Join-Path $ProjectRoot $Output

# 显示标题
Write-Host "CAX Build Script" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 清理阶段（如果指定了 -Clean）
# ============================================================================

if ($Clean) {
    Write-Host "Cleaning..." -ForegroundColor Yellow
    
    # 检查输出文件是否存在
    if (Test-Path $OutputPath) {
        # 删除旧的可执行文件
        Remove-Item $OutputPath -Force
        Write-Host "  Removed: $OutputPath" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# ============================================================================
# 检查 V 语言环境
# ============================================================================

Write-Host "Checking V installation..." -ForegroundColor Yellow

# 获取 V 版本信息
$vVersion = v version 2>&1

# 检查是否成功获取版本
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: V language is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Download from: https://vlang.io" -ForegroundColor Gray
    exit 1
}

Write-Host "  V version: $vVersion" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 编译阶段
# ============================================================================

Write-Host "Building CAX..." -ForegroundColor Yellow

# 根据模式选择编译选项
if ($Release) {
    # 发布模式：启用优化
    Write-Host "  Mode: Release (optimized)" -ForegroundColor Gray
    v -prod -o $OutputPath $SrcDir\cax_simple.v
} else {
    # Debug 模式：无优化，包含调试信息
    Write-Host "  Mode: Debug" -ForegroundColor Gray
    v -o $OutputPath $SrcDir\cax_simple.v
}

# 检查编译结果
if ($LASTEXITCODE -eq 0) {
    # 编译成功
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "  Output: $OutputPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Run with: .\$Output /HELP" -ForegroundColor Cyan
} else {
    # 编译失败
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# 脚本结束
