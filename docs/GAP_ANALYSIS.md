# CAX V Language - 功能对齐差距分析

## 📊 总体状态

| 类别 | 已实现 | 部分实现 | 未实现 | 总计 | 完成率 |
|------|--------|----------|--------|------|--------|
| General Purpose | 20 | 5 | 3 | 28 | 71% |
| Services/Drivers | 8 | 2 | 2 | 12 | 67% |
| Devices | 4 | 0 | 10 | 14 | 29% |
| Windows/Machine | 18 | 2 | 6 | 26 | 69% |
| Message Boxes | 6 | 3 | 0 | 9 | 67% |
| Message Window | 2 | 1 | 2 | 5 | 40% |
| OSD | 4 | 1 | 2 | 7 | 57% |
| Application/Window | 20 | 4 | 12 | 36 | 56% |
| Program/Process | 12 | 2 | 4 | 18 | 67% |
| File/Disk | 25 | 5 | 12 | 42 | 60% |
| Variables | 25 | 5 | 8 | 38 | 66% |
| Verbose/Flags | 6 | 0 | 9 | 15 | 40% |
| **总计** | **150** | **30** | **75** | **255** | **59%** |

---

## 🔴 未实现的重要功能 (High Priority)

### 1. General Purpose - 部分未实现

| 命令 | 原始语法 | 当前状态 | 差距 |
|------|---------|----------|------|
| `/HOTKEY` | `/HOTKEY AS:122` | ❌ Stub | 需要 Windows Hook API |
| `/UNTIL` | `/UNTIL 22:30` | ❌ Stub | 需要时间循环检查 |
| `/CYCLE` | `/CYCLE:20` | ❌ Stub | 需要循环执行逻辑 |
| `/REPEAT` | `/REPEAT:2` | ❌ Stub | 需要命令重放逻辑 |
| `/MEMFREE` | `/MEMFREE:10` | ❌ Stub | 需要内存管理 API |

### 2. Message Boxes - 返回值处理

| 命令 | 原始行为 | 当前状态 | 差距 |
|------|---------|----------|------|
| `/MSIG` | 继续执行下一个参数 | ⚠️ 部分 | 需要正确的流程控制 |
| `/MSIC` | OK 时继续 | ⚠️ 部分 | 需要正确的流程控制 |
| `/MSIY` | YES 时继续 | ⚠️ 部分 | 需要正确的流程控制 |

### 3. OSD - 缺少高级功能

| 命令 | 原始语法 | 当前状态 | 差距 |
|------|---------|----------|------|
| `/OSDRTF` | `/OSDRTF 50 {rtf}` | ❌ Stub | 需要 RTF 渲染 |
| `/OSDFILE` | `/OSDFILE 50 file` | ❌ Stub | 需要文件读取 |

### 4. Window Control - 缺少窗口句柄支持

| 命令 | 原始语法 | 当前状态 | 差距 |
|------|---------|----------|------|
| `/WNC` | `/WNC #000234 -` | ⚠️ 部分 | 需要支持窗口句柄 |
| `/WINTRANSP` | `/WINTRANSP $0c0c0c0` | ⚠️ 部分 | 需要支持 HEX 颜色 |
| `/WINMSGSEND` | 4 个参数 | ⚠️ 部分 | Stub 实现 |

### 5. Process Control - 缺少实际功能

| 命令 | 原始行为 | 当前状态 | 差距 |
|------|---------|----------|------|
| `/PRCLIST` | 列出进程和 PID | ❌ Stub | 需要 Toolhelp32 API |
| `/KILLPRC` | 实际杀死进程 | ❌ Stub | 需要 TerminateProcess |
| `/KILLALL` | 杀死所有匹配进程 | ❌ Stub | 需要进程枚举 |
| `/RUN` | 实际运行程序 | ❌ Stub | 需要 CreateProcess |

### 6. File Operations - 缺少实际功能

| 命令 | 原始行为 | 当前状态 | 差距 |
|------|---------|----------|------|
| `/CPY` | 实际复制文件 | ❌ Stub | 需要 SHFileOperation |
| `/DEL` | 实际删除到回收站 | ❌ Stub | 需要 SHFileOperation |
| `/MD5FILE` | 计算 MD5 哈希 | ❌ Stub | 需要加密 API |
| `/PROP` | 显示文件属性对话框 | ❌ Stub | 需要 ShellExecuteEx |

### 7. Variables - 缺少系统变量

| 变量 | 原始功能 | 当前状态 | 差距 |
|------|---------|----------|------|
| `%!TICK!%` | GetTickCount | ⚠️ 部分 | 需要 Windows API |
| `%!FMEM!%` | 空闲内存 MB | ❌ 返回 0 | 需要 GlobalMemoryStatusEx |
| `%!IPADS!%` | IP 地址列表 | ❌ 返回空 | 需要网络 API |
| `%!CPUSPD!%` | CPU 频率 | ❌ 返回 0 | 需要注册表或 API |
| `%!CLIPBRD!%` | 剪贴板内容 | ❌ 返回空 | 需要剪贴板 API |

### 8. 特殊语法支持

| 功能 | 原始支持 | 当前状态 | 差距 |
|------|---------|----------|------|
| `\n` 换行 | 支持 | ❌ 未实现 | 需要字符串解析 |
| `\t` 制表符 | 支持 | ❌ 未实现 | 需要字符串解析 |
| `#12345` 窗口句柄 | 支持 | ❌ 未实现 | 需要句柄解析 |
| `$0c0c0c0` HEX 颜色 | 支持 | ❌ 未实现 | 需要颜色解析 |
| `##registry` 注册表 | 支持 | ❌ 未实现 | 需要注册表 API |

---

## 🟡 部分实现的功能 (Medium Priority)

### 1. 窗口操作命令

当前实现了命令解析，但都是 Stub：
- `/WNC`, `/WNT`, `/WNH`, `/WNS` 等 20+ 个窗口命令
- 需要实现 Windows API: FindWindow, ShowWindow, EnableWindow 等

### 2. 服务管理

当前实现了命令解析，但都是 Stub：
- `/SVC~I`, `/SVC~U`, `/SVCSTOP` 等
- 需要 Windows Service API: CreateService, StartService 等

### 3. 设备管理

当前实现了命令解析，但都是 Stub：
- `/DEVLIST`, `/DEVEJIN`, `/DEVENIN` 等
- 需要 SetupAPI: SetupDiGetClassDevs 等

---

## 📋 优先级建议

### 🔴 高优先级 (影响核心功能)

1. **窗口操作实际功能** - 20+ 个命令
2. **进程管理实际功能** - PRCLIST, KILLPRC, RUN
3. **文件操作实际功能** - CPY, DEL, MVE
4. **特殊字符解析** - \n, \t, #handle
5. **系统变量完善** - FMEM, CLIPBRD, TICK

### 🟡 中优先级 (增强功能)

6. **消息框流程控制** - MSIG, MSIC, MSIY
7. **OSD 高级功能** - OSDRTF, OSDFILE
8. **服务管理实际功能**
9. **设备管理实际功能**
10. **注册表变量支持**

### 🟢 低优先级 (高级功能)

11. **HOTKEY 支持**
12. **CYCLE/REPEAT 循环**
13. **MD5/SHA1 计算**
14. **网络功能**
15. **HEX 颜色支持**

---

## 🎯 下一步行动

### 阶段 1: 核心功能 (1-2 周)
- [ ] 实现窗口操作 API (FindWindow, ShowWindow 等)
- [ ] 实现进程管理 API (CreateProcess, TerminateProcess 等)
- [ ] 实现文件操作 API (CopyFile, DeleteFile 等)
- [ ] 实现特殊字符解析 (\n, \t)

### 阶段 2: 系统功能 (2-3 周)
- [ ] 实现系统变量 (FMEM, TICK, CLIPBRD)
- [ ] 实现消息框流程控制
- [ ] 实现服务管理 API
- [ ] 实现设备管理 API

### 阶段 3: 高级功能 (3-4 周)
- [ ] 实现 OSD RTF 支持
- [ ] 实现 MD5/SHA1 计算
- [ ] 实现注册表变量
- [ ] 实现 HEX 颜色解析

---

## 📝 结论

**当前完成度：59% (150/255)**

- ✅ **已实现**: 150 个功能（命令解析、变量扩展、测试框架）
- ⚠️ **部分实现**: 30 个功能（Stub 需要实际 API）
- ❌ **未实现**: 75 个功能（需要 Windows API 调用）

**主要差距**：
1. Windows API 调用（窗口、进程、文件操作）
2. 系统信息获取（内存、CPU、网络）
3. 特殊语法解析（转义字符、句柄、颜色）
4. 流程控制（条件执行、循环）

**优势**：
- ✅ 完整的命令解析框架
- ✅ 变量扩展系统
- ✅ 测试框架完善
- ✅ OSD 功能已实现（PowerShell 方案）
