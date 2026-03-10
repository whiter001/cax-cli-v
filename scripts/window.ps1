# ============================================================================
# CAX 窗口操作脚本 - PowerShell 实现
# ============================================================================
# 功能：使用 Windows API 操作窗口（关闭、隐藏、最小化等）
# 技术：通过 P/Invoke 调用 user32.dll
# 支持的窗口操作：
#   CLOSE, DESTROY, HIDE, SHOW, MINIMIZE, MAXIMIZE, RESTORE
#   DISABLE, ENABLE, TOPMOST, NOTOPMOST, ACTIVATE, TOBACK
# 参数：
#   Action - 操作类型
#   ClassName - Windows 窗口类名
#   WindowName - Windows 窗口标题
# ============================================================================

param(
    [string]$Action,        # 操作类型（CLOSE, HIDE, SHOW 等）
    [string]$ClassName,     # 窗口类名
    [string]$WindowName,    # 窗口标题
    [string]$ExtraParam     # 额外参数（暂未使用）
)

# ============================================================================
# 定义 Windows API 封装类
# ============================================================================

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

/// <summary>
/// Windows User32 API 封装
/// 提供窗口查找、显示控制、消息发送等功能
/// </summary>
public class User32 {
    /// <summary>
    /// 查找窗口（通过类名和窗口名）
    /// </summary>
    /// <param name="lpClassName">窗口类名</param>
    /// <param name="lpWindowName">窗口标题</param>
    /// <returns>窗口句柄，找不到返回 IntPtr.Zero</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    /// <summary>
    /// 显示/隐藏窗口
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <param name="nCmdShow">显示命令</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    
    /// <summary>
    /// 启用/禁用窗口
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <param name="bEnable">true=启用，false=禁用</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool EnableWindow(IntPtr hWnd, bool bEnable);
    
    /// <summary>
    /// 设置前台窗口（激活）
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    /// <summary>
    /// 将窗口置于顶部
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool BringWindowToTop(IntPtr hWnd);
    
    /// <summary>
    /// 移动窗口
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <param name="X">新 X 坐标</param>
    /// <param name="Y">新 Y 坐标</param>
    /// <param name="nWidth">新宽度</param>
    /// <param name="nHeight">新高度</param>
    /// <param name="bRepaint">是否重绘</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    
    /// <summary>
    /// 设置窗口位置（Z 序）
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <param name="hWndInsertAfter">Z 序位置（HWND_TOP, HWND_BOTTOM 等）</param>
    /// <param name="X">X 坐标</param>
    /// <param name="Y">Y 坐标</param>
    /// <param name="cx">宽度</param>
    /// <param name="cy">高度</param>
    /// <param name="uFlags">标志位</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    
    /// <summary>
    /// 发送消息到窗口
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <param name="Msg">消息 ID</param>
    /// <param name="wParam">wParam 参数</param>
    /// <param name="lParam">lParam 参数</param>
    /// <returns>消息处理结果</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    /// <summary>
    /// 同步发送消息到窗口
    /// </summary>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    /// <summary>
    /// 获取窗口矩形
    /// </summary>
    /// <param name="hWnd">窗口句柄</param>
    /// <param name="lpRect">输出矩形</param>
    /// <returns>成功返回 true</returns>
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    
    /// <summary>
    /// 窗口矩形结构
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;    // 左边界
        public int Top;     // 上边界
        public int Right;   // 右边界
        public int Bottom;  // 下边界
    }
    
    // ========================================================================
    // 常量定义
    // ========================================================================
    
    // ShowWindow 命令常量
    public const int SW_HIDE = 0;           // 隐藏窗口
    public const int SW_SHOWNORMAL = 1;     // 正常显示
    public const int SW_SHOWMINIMIZED = 2;  // 最小化
    public const int SW_SHOWMAXIMIZED = 3;  // 最大化
    public const int SW_SHOWNOACTIVATE = 4; // 显示但不激活
    public const int SW_SHOW = 5;           // 显示
    public const int SW_MINIMIZE = 6;       // 最小化（不激活）
    public const int SW_SHOWMINNOACTIVE = 7;// 最小化（不激活）
    public const int SW_SHOWNA = 8;         // 显示（保持状态）
    public const int SW_RESTORE = 9;        // 恢复
    public const int SW_SHOWDEFAULT = 10;   // 默认显示
    
    // 窗口消息常量
    public const int WM_CLOSE = 0x0010;     // 关闭窗口
    public const int WM_DESTROY = 0x0002;   // 销毁窗口
    
    // SetWindowPos 窗口位置常量
    public static readonly IntPtr HWND_TOP = new IntPtr(0);         // 顶层
    public static readonly IntPtr HWND_BOTTOM = new IntPtr(1);      // 底层
    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);    // 最顶层
    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);  // 非最顶层
    
    // SetWindowPos 标志常量
    public const uint SWP_NOSIZE = 0x0001;      // 保持大小
    public const uint SWP_NOMOVE = 0x0002;      // 保持位置
    public const uint SWP_NOACTIVATE = 0x0010;  // 不激活
}
"@

# ============================================================================
# 查找目标窗口
# ============================================================================

# 使用 FindWindow API 查找窗口
$hWnd = [User32]::FindWindow($ClassName, $WindowName)

# 检查是否找到窗口
if ($hWnd -eq [IntPtr]::Zero) {
    Write-Host "Window not found: Class='$ClassName' Name='$WindowName'"
    exit 1
}

Write-Host "Found window handle: $hWnd"

# ============================================================================
# 执行指定的窗口操作
# ============================================================================

switch ($Action) {
    'CLOSE' {
        # 发送 WM_CLOSE 消息关闭窗口
        [User32]::PostMessage($hWnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
        Write-Host "Window closed"
    }
    'DESTROY' {
        # 发送 WM_DESTROY 消息销毁窗口
        [User32]::PostMessage($hWnd, 0x0002, [IntPtr]::Zero, [IntPtr]::Zero)
        Write-Host "Window destroyed"
    }
    'HIDE' {
        # 调用 ShowWindow(SW_HIDE) 隐藏窗口
        [User32]::ShowWindow($hWnd, [User32]::SW_HIDE)
        Write-Host "Window hidden"
    }
    'SHOW' {
        # 调用 ShowWindow(SW_SHOWNORMAL) 显示窗口
        [User32]::ShowWindow($hWnd, [User32]::SW_SHOWNORMAL)
        Write-Host "Window shown"
    }
    'MINIMIZE' {
        # 调用 ShowWindow(SW_MINIMIZE) 最小化窗口
        [User32]::ShowWindow($hWnd, [User32]::SW_MINIMIZE)
        Write-Host "Window minimized"
    }
    'MAXIMIZE' {
        # 调用 ShowWindow(SW_SHOWMAXIMIZED) 最大化窗口
        [User32]::ShowWindow($hWnd, [User32]::SW_SHOWMAXIMIZED)
        Write-Host "Window maximized"
    }
    'RESTORE' {
        # 调用 ShowWindow(SW_RESTORE) 恢复窗口
        [User32]::ShowWindow($hWnd, [User32]::SW_RESTORE)
        Write-Host "Window restored"
    }
    'DISABLE' {
        # 调用 EnableWindow(false) 禁用窗口
        [User32]::EnableWindow($hWnd, $false)
        Write-Host "Window disabled"
    }
    'ENABLE' {
        # 调用 EnableWindow(true) 启用窗口
        [User32]::EnableWindow($hWnd, $true)
        Write-Host "Window enabled"
    }
    'TOPMOST' {
        # 调用 SetWindowPos(HWND_TOPMOST) 设为顶层窗口
        [User32]::SetWindowPos($hWnd, [User32]::HWND_TOPMOST, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
        Write-Host "Window set to topmost"
    }
    'NOTOPMOST' {
        # 调用 SetWindowPos(HWND_NOTOPMOST) 取消顶层
        [User32]::SetWindowPos($hWnd, [User32]::HWND_NOTOPMOST, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
        Write-Host "Window set to not topmost"
    }
    'ACTIVATE' {
        # 调用 SetForegroundWindow 激活窗口（置前）
        [User32]::SetForegroundWindow($hWnd)
        Write-Host "Window activated"
    }
    'TOBACK' {
        # 调用 SetWindowPos(HWND_BOTTOM) 置底窗口
        [User32]::SetWindowPos($hWnd, [User32]::HWND_BOTTOM, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
        Write-Host "Window sent to back"
    }
    default {
        Write-Host "Unknown action: $Action"
        exit 1
    }
}

# 脚本结束
