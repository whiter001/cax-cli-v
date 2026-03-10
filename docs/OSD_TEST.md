# CAX OSD 测试指南

## ✅ OSD 功能已实现

### 测试命令

```bash
# 基本测试 - 显示 3 秒
v run src/cax_simple.v /OSDTEXT 30 "Hello OSD"

# 显示 5 秒
v run src/cax_simple.v /OSDTEXT 50 "Test Message"

# 显示 10 秒
v run src/cax_simple.v /OSDTEXT 100 "Long OSD Test"
```

### 预期效果

执行命令后，你应该看到：

1. **控制台输出**
   ```
   [OSDTEXT] Showing OSD: 3s - "Hello OSD"
   ```

2. **屏幕显示**
   - 屏幕底部中央出现黑色半透明窗口
   - 亮绿色 (Lime) 文字显示 "Hello OSD"
   - Verdana 48pt 粗体字体
   - 3 秒后自动消失

### 故障排除

#### 问题：只看到控制台输出，没有 OSD 窗口

**解决方案 1**: 检查 PowerShell 执行策略
```powershell
Get-ExecutionPolicy
# 如果是 Restricted，需要更改
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

**解决方案 2**: 直接测试 PowerShell 脚本
```powershell
powershell -ExecutionPolicy Bypass -File scripts/osd.ps1 -TimeoutSec 3 -Text "Direct Test"
```

**解决方案 3**: 检查脚本路径
```bash
# 确认脚本存在
ls scripts/osd.ps1
```

#### 问题：OSD 窗口一闪而过

**原因**: timeout 参数太小
**解决**: 使用更大的值，如 50 (5 秒)

### 技术细节

- **显示位置**: 屏幕底部中央
- **窗口大小**: 60% 屏幕宽度 × 120px 高度
- **背景**: 黑色，90% 不透明度
- **文字**: 亮绿色 (#00FF00), Verdana 48pt 粗体
- **层级**: 顶层窗口 (TopMost)

### 相关文件

- `src/cax_simple.v` - 主程序
- `scripts/osd.ps1` - PowerShell OSD 脚本
- `docs/OSD_IMPLEMENTATION.md` - 实现文档

### 验证步骤

1. 运行测试命令
2. 观察屏幕底部
3. 应该看到黑色窗口带绿色文字
4. 等待指定秒数后自动关闭

如果看不到 OSD 窗口，请按故障排除步骤检查。
