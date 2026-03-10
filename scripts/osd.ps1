# ============================================================================
# CAX OSD 显示脚本 - PowerShell 实现
# ============================================================================
# 功能：在屏幕底部显示半透明 OSD（On-Screen Display）
# 技术：使用 Windows Forms 和 GDI+ 渲染
# 特点：
#   - 透明背景（使用 TransparencyKey 技术）
#   - 亮绿色文字（#00FF00）
#   - Verdana 48pt 粗体字体
#   - 自动定时关闭
# 参数：
#   TimeoutSec - 显示时间（秒）
#   Text - 要显示的文本内容
# ============================================================================

param(
    [int]$TimeoutSec = 20,      # 默认显示 20 秒
    [string]$Text = "OSD Test"  # 默认文本
)

# 转换为毫秒
$TimeoutMs = $TimeoutSec * 100

# 加载必要的 .NET 程序集
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================================
# 创建 OSD 窗口
# ============================================================================

# 创建 Windows Forms 窗体
$f = New-Object System.Windows.Forms.Form

# 设置窗体属性
$f.Text = "CAX OSD"              # 窗口标题（不显示）
$f.StartPosition = 'Manual'      # 手动定位
$f.FormBorderStyle = 'None'      # 无边框
$f.TopMost = $true               # 顶层窗口
$f.ShowInTaskbar = $false        # 不显示在任务栏

# 设置透明背景
# 关键：BackColor 和 TransparencyKey 必须相同才能实现透明
$f.BackColor = [System.Drawing.Color]::White
$f.TransparencyKey = [System.Drawing.Color]::White  # 白色变为透明
$f.Opacity = 1.0                  # 完全不透明（背景已透明）

# ============================================================================
# 计算窗口位置和大小
# ============================================================================

# 获取主屏幕尺寸
$sw = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$sh = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# 计算 OSD 尺寸
$fw = [int]($sw * 0.6)   # 宽度：屏幕的 60%
$fh = 120                 # 高度：120 像素

# 计算位置：屏幕底部中央
$f.Left = [int](($sw - $fw) / 2)  # 水平居中
$f.Top = $sh - $fh - 100          # 距离底部 100 像素
$f.Width = $fw
$f.Height = $fh

# ============================================================================
# 创建文本标签
# ============================================================================

# 创建 Label 控件
$l = New-Object System.Windows.Forms.Label

# 设置标签属性
$l.Text = $Text                   # 显示文本
$l.AutoSize = $false              # 不自动调整大小
$l.Dock = 'Fill'                  # 填充整个窗体
$l.TextAlign = 'MiddleCenter'     # 居中对齐

# 设置字体：Verdana 48pt 粗体
$l.Font = New-Object System.Drawing.Font('Verdana', 48, [System.Drawing.FontStyle]::Bold)

# 设置颜色：亮绿色文字（RGB: 0, 255, 0）
$l.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)

# 标签背景设为白色（与窗体背景相同，因此透明）
$l.BackColor = [System.Drawing.Color]::White

# 将标签添加到窗体
$f.Controls.Add($l)

# ============================================================================
# 显示 OSD
# ============================================================================

# 显示窗体
$f.Show()

# 等待指定时间
Start-Sleep -Milliseconds $TimeoutMs

# ============================================================================
# 清理资源
# ============================================================================

# 关闭窗体
$f.Close()

# 释放资源
$f.Dispose()

# 脚本结束
