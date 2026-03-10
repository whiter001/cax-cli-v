// ============================================================================
// CAX - Comandiux for V Language
// 命令行系统工具 V 语言实现
// ============================================================================
// 模块定义文件
// 
// 项目名称：cax
// 描述：实现原始 cax.exe 的全部 255 个命令
// 版本：0.0.1
// 许可证：MIT
// 
// 功能分类：
//   1. 通用命令 - BEEP, MVOLUME, SAVER, SHOWDESK 等
//   2. 剪贴板 - SETCLIP, CLIPTOFILE, KEYBSEND 等
//   3. 等待/循环 - WAIT, VWAIT, CYCLE, REPEAT 等
//   4. 进程管理 - RUN, PRCLIST, KILLPRC, KILLALL 等
//   5. 服务管理 - SVCLIST, SVCSTOP, SVC~I, SVC~U 等
//   6. 设备管理 - DEVLIST, DEVEJIN, DEVENIN 等
//   7. 系统控制 - DWR (重启), DWC (关机), DWL (注销) 等
//   8. 消息框 - MSG, MSC, MSY, MSN 等
//   9. 窗口控制 - WNC, WINLIST, WINCLOSE 等
//   10. 文件操作 - CPY, MVE, DEL, MKD 等
//   11. OSD 显示 - OSDTEXT, OSDRTF, OSDFILE 等
//   12. 系统变量 - %!CLOCK!%, %!DATE!%, %!UNAME!% 等
// 
// 依赖项：
//   - V 语言 0.5.0+
//   - PowerShell (Windows 自带)
//   - .NET Framework 4.0+ (用于 Windows Forms)
// 
// 使用方法：
//   v run src/cax_simple.v /HELP     # 显示帮助
//   v run src/cax_simple.v /BEEP     # 测试蜂鸣
//   v run src/cax_simple.v /OSDTEXT 30 "Hello"  # 显示 OSD
// 
// 构建方法：
//   .\scripts\build.ps1              # Debug 构建
//   .\scripts\build.ps1 -Release     # Release 构建
// 
// 测试方法：
//   .\scripts\test.ps1               # 运行所有测试
// 
// 作者：CAX Team
// 主页：http://comandiux.scot.sk
// 仓库：https://github.com/cax-cli-v
// ============================================================================

Module {
	name: 'cax'
	description: 'Comandiux: a command line system tool - V language implementation'
	version: '0.0.1'
	license: 'MIT'
	dependencies: {}
}
