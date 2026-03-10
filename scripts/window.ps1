# CAX Window Operations Helper
# PowerShell script for window manipulation

param(
    [string]$Action,
    [string]$ClassName,
    [string]$WindowName,
    [string]$ExtraParam
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class User32 {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool EnableWindow(IntPtr hWnd, bool bEnable);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool BringWindowToTop(IntPtr hWnd);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
    
    public const int SW_HIDE = 0;
    public const int SW_SHOWNORMAL = 1;
    public const int SW_SHOWMINIMIZED = 2;
    public const int SW_SHOWMAXIMIZED = 3;
    public const int SW_SHOWNOACTIVATE = 4;
    public const int SW_SHOW = 5;
    public const int SW_MINIMIZE = 6;
    public const int SW_SHOWMINNOACTIVE = 7;
    public const int SW_SHOWNA = 8;
    public const int SW_RESTORE = 9;
    public const int SW_SHOWDEFAULT = 10;
    
    public const int WM_CLOSE = 0x0010;
    public const int WM_DESTROY = 0x0002;
    
    public static readonly IntPtr HWND_TOP = new IntPtr(0);
    public static readonly IntPtr HWND_BOTTOM = new IntPtr(1);
    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    
    public const uint SWP_NOSIZE = 0x0001;
    public const uint SWP_NOMOVE = 0x0002;
    public const uint SWP_NOACTIVATE = 0x0010;
}
"@

# Find window
$hWnd = [User32]::FindWindow($ClassName, $WindowName)

if ($hWnd -eq [IntPtr]::Zero) {
    Write-Host "Window not found: Class='$ClassName' Name='$WindowName'"
    exit 1
}

Write-Host "Found window handle: $hWnd"

# Execute action
switch ($Action) {
    'CLOSE' {
        [User32]::PostMessage($hWnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
        Write-Host "Window closed"
    }
    'DESTROY' {
        [User32]::PostMessage($hWnd, 0x0002, [IntPtr]::Zero, [IntPtr]::Zero)
        Write-Host "Window destroyed"
    }
    'HIDE' {
        [User32]::ShowWindow($hWnd, [User32]::SW_HIDE)
        Write-Host "Window hidden"
    }
    'SHOW' {
        [User32]::ShowWindow($hWnd, [User32]::SW_SHOWNORMAL)
        Write-Host "Window shown"
    }
    'MINIMIZE' {
        [User32]::ShowWindow($hWnd, [User32]::SW_MINIMIZE)
        Write-Host "Window minimized"
    }
    'MAXIMIZE' {
        [User32]::ShowWindow($hWnd, [User32]::SW_SHOWMAXIMIZED)
        Write-Host "Window maximized"
    }
    'RESTORE' {
        [User32]::ShowWindow($hWnd, [User32]::SW_RESTORE)
        Write-Host "Window restored"
    }
    'DISABLE' {
        [User32]::EnableWindow($hWnd, $false)
        Write-Host "Window disabled"
    }
    'ENABLE' {
        [User32]::EnableWindow($hWnd, $true)
        Write-Host "Window enabled"
    }
    'TOPMOST' {
        [User32]::SetWindowPos($hWnd, [User32]::HWND_TOPMOST, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
        Write-Host "Window set to topmost"
    }
    'NOTOPMOST' {
        [User32]::SetWindowPos($hWnd, [User32]::HWND_NOTOPMOST, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
        Write-Host "Window set to not topmost"
    }
    'ACTIVATE' {
        [User32]::SetForegroundWindow($hWnd)
        Write-Host "Window activated"
    }
    'TOBACK' {
        [User32]::SetWindowPos($hWnd, [User32]::HWND_BOTTOM, 0, 0, 0, 0, [User32]::SWP_NOSIZE -bor [User32]::SWP_NOMOVE)
        Write-Host "Window sent to back"
    }
    default {
        Write-Host "Unknown action: $Action"
        exit 1
    }
}
