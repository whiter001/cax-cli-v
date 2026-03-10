# CAX OSD 功能实现

## ✅ 真实 OSD 效果已实现

### 📊 效果说明

执行命令：
```bash
v run src/cax_simple.v /OSDTEXT 30 "Hello OSD"
```

**实际显示效果：**

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                                                         │
│                                                         │
│                        (屏幕中央)                        │
│                                                         │
│                                                         │
│                                                         │
│                                                         │
│              ████████████████████████████               │
│              █                         █                │
│              █   ███████████████████   █                │
│              █   █                 █   █                │
│              █   █  H E L L O   O  █   █  ← 亮绿色文字   │
│              █   █      S D        █   █    (Lime Green)│
│              █   █                 █   █    Verdana 48pt │
│              █   ███████████████████   █    粗体         │
│              █                         █                │
│              ████████████████████████████               │
│                                                         │
│                  (屏幕底部，停留 3 秒)                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 🎯 技术实现

1. **V 语言调用 PowerShell**
   - V 代码 → 批处理文件 → PowerShell → Windows Forms

2. **显示流程**
   ```
   cax_simple.v
       ↓ (os.execute)
   scripts/osd.bat
       ↓ (创建临时 PS1)
   %TEMP%\cax_osd_*.ps1
       ↓ (PowerShell)
   System.Windows.Forms.Form
       ↓ (显示 3 秒)
   自动关闭
   ```

3. **窗口属性**
   - 位置：屏幕底部中央
   - 大小：60% 屏幕宽度 × 120px 高度
   - 背景：黑色，90% 不透明度
   - 文字：亮绿色 (#00FF00), Verdana 48pt 粗体
   - 层级：顶层 (TopMost)

### 📝 使用方法

```bash
# 基本用法
v run src/cax_simple.v /OSDTEXT <timeout> "text"
# timeout 单位：秒/10 (30 = 3 秒)

# 示例
v run src/cax_simple.v /OSDTEXT 30 "Hello OSD"     # 显示 3 秒
v run src/cax_simple.v /OSDTEXT 50 "Test Message"  # 显示 5 秒
v run src/cax_simple.v /OSDTEXT 100 "Long OSD"     # 显示 10 秒
```

### 🔧 文件结构

```
cax-cli-v/
├── src/
│   └── cax_simple.v          # 主程序，包含 OSD 调用
├── scripts/
│   ├── osd.bat               # OSD 启动脚本
│   └── osd.ps1               # PowerShell OSD 脚本（备用）
└── docs/
    └── OSD_IMPLEMENTATION.md # 本文档
```

### ✅ 测试结果

| 测试项 | 状态 | 说明 |
|--------|------|------|
| 命令解析 | ✅ | 正确解析 timeout 和 text |
| PowerShell 调用 | ✅ | 成功执行 PowerShell 脚本 |
| 窗口显示 | ✅ | 显示黑色半透明窗口 |
| 文字渲染 | ✅ | 亮绿色 Verdana 48pt 粗体 |
| 定时关闭 | ✅ | 按指定时间自动关闭 |
| 位置正确 | ✅ | 屏幕底部中央 |

### 🎨 与原始 cax.exe 对比

| 特性 | 原始 cax.exe | 本实现 |
|------|-------------|--------|
| 显示方式 | GDI+ OSD | Windows Forms |
| 文字颜色 | 亮绿色 | 亮绿色 ✅ |
| 字体 | Verdana 72pt | Verdana 48pt |
| 位置 | 屏幕底部 | 屏幕底部 ✅ |
| 透明度 | 完全透明背景 | 90% 不透明度 |
| 超时控制 | 精确 | 精确 ✅ |

### 🚀 未来改进

1. 使用纯 Windows API (GDI+) 实现更轻量级 OSD
2. 支持 RTF 格式显示
3. 支持自定义字体大小和颜色
4. 支持多行显示
5. 支持动画效果

### 📖 参考

- 原始 cax.exe: http://comandiux.scot.sk
- Windows Forms: https://docs.microsoft.com/en-us/dotnet/desktop/winforms/
- PowerShell System.Drawing: https://docs.microsoft.com/en-us/dotnet/api/system.drawing
