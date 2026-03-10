# CAX OSD - 透明背景版本

## ✅ 已实现透明背景 OSD

### 🎯 效果对比

#### 之前（黑色半透明背景）
```
┌─────────────────────────────────────────┐
│                                         │
│    ████████████████████████████         │
│    █                         █          │
│    █   ███████████████████   █          │
│    █   █                 █   █  黑色背景 │
│    █   █  H E L L O   O  █   █          │
│    █   █      S D        █   █          │
│    █   ███████████████████   █          │
│    █                         █          │
│    ████████████████████████████         │
│                                         │
└─────────────────────────────────────────┘
```

#### 现在（真正透明背景）✨
```
┌─────────────────────────────────────────┐
│                                         │
│         (完全透明，看到桌面)              │
│                                         │
│    ████████████████████████████         │
│    █   ███████████████████   █          │
│    █   █  H E L L O   O  █   █  亮绿色文字 │
│    █   █      S D        █   █          │
│    █   ███████████████████   █          │
│                                         │
│         (完全透明，看到桌面)              │
│                                         │
└─────────────────────────────────────────┘
```

### 🔧 技术实现

使用 **TransparencyKey** 技术：

```powershell
# 设置背景色为白色
$f.BackColor = [System.Drawing.Color]::White

# 将白色设为透明色
$f.TransparencyKey = [System.Drawing.Color]::White

# 标签背景也设为白色（透明）
$l.BackColor = [System.Drawing.Color]::White
```

**原理**：
- Windows Forms 会将与 `TransparencyKey` 相同颜色的像素变为透明
- 背景是白色 → 白色透明 → 显示桌面
- 文字是亮绿色 → 不透明 → 显示文字

### 📊 显示特性

| 特性 | 值 |
|------|-----|
| 背景 | ✅ 完全透明 |
| 文字颜色 | 亮绿色 (#00FF00) |
| 文字字体 | Verdana 48pt 粗体 |
| 窗口层级 | 顶层 (TopMost) |
| 位置 | 屏幕底部中央 |
| 大小 | 60% 屏幕宽度 × 120px |

### 🚀 使用方法

```bash
# 基本用法
v run src/cax_simple.v /OSDTEXT 30 "Hello OSD"

# 显示 5 秒
v run src/cax_simple.v /OSDTEXT 50 "Test Message"

# 显示 10 秒
v run src/cax_simple.v /OSDTEXT 100 "Long OSD"
```

### ✅ 优势

1. **更好的视觉效果** - 文字仿佛直接显示在桌面上
2. **不遮挡内容** - 可以看到桌面背景和其他窗口
3. **更专业** - 类似系统级 OSD 的效果
4. **无闪烁** - 使用 TransparencyKey 而非 Alpha 混合

### 🎨 与原始 cax.exe 对比

| 特性 | cax.exe | 本实现 |
|------|---------|--------|
| 背景 | 透明 | ✅ 透明 |
| 文字颜色 | 亮绿色 | ✅ 亮绿色 |
| 字体 | Verdana | ✅ Verdana |
| 位置 | 底部 | ✅ 底部 |
| 层级 | 顶层 | ✅ 顶层 |

### 📝 相关文件

- `scripts/osd.ps1` - PowerShell 脚本（透明背景版本）
- `src/cax_simple.v` - V 语言主程序
- `docs/OSD_TEST.md` - 测试指南

### ⚠️ 故障排除

#### 问题：背景不透明

**检查**：确保 `BackColor` 和 `TransparencyKey` 都是白色

```powershell
$f.BackColor = [System.Drawing.Color]::White
$f.TransparencyKey = [System.Drawing.Color]::White
$l.BackColor = [System.Drawing.Color]::White
```

#### 问题：文字也透明了

**原因**：文字颜色与背景色相同
**解决**：确保文字颜色不是白色

```powershell
$l.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)  # 亮绿色
```

### 📖 参考

- TransparencyKey 属性：https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.form.transparencykey
- Windows Forms 透明：https://docs.microsoft.com/en-us/dotnet/desktop/winforms/advanced/using-transparency
