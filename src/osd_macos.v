// ============================================================================
// CAX Native OSD - macOS 实现
// ============================================================================
// 功能：在屏幕底部显示半透明 OSD（On-Screen Display）
// 平台：macOS
// 策略：
//   1. 优先使用 Python3 + tkinter 创建真正的浮层窗口（效果最佳）
//   2. 降级使用 osascript 显示系统通知（无需额外依赖）
// 参数：
//   第一个参数：显示的文本
//   -t <秒数>：显示时间（秒），默认 5 秒
// 用法：
//   v run src/osd_macos.v "Hello OSD" -t 3
//   v -o osd_macos src/osd_macos.v && ./osd_macos "Hello" -t 5
// ============================================================================

module main

import os
import time

fn main() {
	mut timeout_sec := 5
	mut text := 'OSD Test'

	args := os.args
	mut i := 1
	for i < args.len {
		if args[i] == '-t' && i + 1 < args.len {
			timeout_sec = args[i + 1].int()
			i += 2
		} else if args[i] == '-text' && i + 1 < args.len {
			text = args[i + 1]
			i += 2
		} else if !args[i].starts_with('-') {
			text = args[i]
			i++
		} else {
			i++
		}
	}

	show_osd_macos(text, timeout_sec)
}

// ============================================================================
// macOS OSD 显示函数
// ============================================================================
// 策略 1：Python3 tkinter 透明浮层（效果接近 Windows 版本）
// 策略 2：osascript display notification（系统通知，无需额外依赖）
// ============================================================================
fn show_osd_macos(text string, timeout_sec int) {
	timeout_ms := timeout_sec * 1000

	// 尝试 Python3 tkinter 浮层
	if try_python_osd(text, timeout_ms) {
		return
	}

	// 降级：osascript 系统通知
	notify_via_osascript(text, timeout_sec)
}

// ============================================================================
// Python3 tkinter 透明浮层实现
// ============================================================================
// 特点：
//   - 屏幕底部居中，半透明黑色背景
//   - 亮绿色文字（#00FF00），Verdana 字体
//   - 自动超时关闭（无需用户干预）
// 返回：true 表示成功显示，false 表示 Python3/tkinter 不可用
// ============================================================================
fn try_python_osd(text string, timeout_ms int) bool {
	// 检查 python3 是否可用
	check := os.execute('which python3 2>/dev/null')
	if check.exit_code != 0 {
		return false
	}

	pid := os.getpid()
	tmp_py := '/tmp/cax_osd_${pid}.py'

	// 转义文本用于嵌入 Python 字符串（双引号需要转义）
	safe := text.replace('\\', '\\\\').replace('"', '\\"').replace('\r', '').replace('\n',
		' ')

	// 构建 Python 脚本（使用字符串拼接避免 V 插值与 Python f-string 冲突）
	// Python 的 {w}、{h} 等在 V 单引号字符串中是字面字符，不会被 V 插值
	py_script := 'import tkinter as tk\n' + 'import sys\n' + 'try:\n'
		+ '    root = tk.Tk()\n' + 'except Exception as e:\n'
		+ '    sys.exit(1)  # tkinter not available\n' + 'root.overrideredirect(True)\n'
		+ 'root.wm_attributes("-topmost", True)\n' + 'root.wm_attributes("-alpha", 0.88)\n'
		+ 'root.configure(bg="black")\n' + 'sw = root.winfo_screenwidth()\n'
		+ 'sh = root.winfo_screenheight()\n' + 'text = "' + safe + '"\n'
		+ 'char_w = 28  # approx pixel width per char at size 40\n'
		+ 'w = min(sw - 40, max(600, len(text) * char_w + 120))\n' + 'h = 100\n'
		+ 'x = (sw - w) // 2\n' + 'y = sh - h - 60\n'
		+ 'root.geometry(f"{w}x{h}+{x}+{y}")\n' + 'try:\n'
		+ '    from tkinter import font as tkfont\n'
		+ '    f = tkfont.Font(family="Verdana", size=40, weight="bold")\n'
		+ 'except Exception:\n' + '    f = ("Verdana", 40, "bold")\n'
		+ 'lbl = tk.Label(root, text=text, font=f, fg="#00FF00", bg="black",\n'
		+ '               padx=20, pady=10, anchor="center")\n'
		+ 'lbl.place(relx=0.5, rely=0.5, anchor="center")\n' + 'root.after('
		+ timeout_ms.str() + ', root.destroy)\n' + 'root.mainloop()\n'

	os.write_file(tmp_py, py_script) or { return false }

	result := os.execute('python3 "${tmp_py}" 2>/dev/null')
	os.rm(tmp_py) or {}

	// exit_code == 1 表示 tkinter 不可用（sys.exit(1)）
	return result.exit_code == 0
}

// ============================================================================
// osascript 系统通知降级实现
// ============================================================================
// 使用 macOS 通知中心显示通知，不需要任何外部依赖
// osascript 在所有 macOS 版本上均可用
// ============================================================================
fn notify_via_osascript(text string, timeout_sec int) {
	// 转义双引号，防止 AppleScript 注入
	escaped := text.replace('\\', '\\\\').replace('"', '\\"')

	println('[OSD] ${text} (${timeout_sec}s)')

	// 显示系统通知
	os.execute('osascript -e \'display notification "${escaped}" with title "OSD" subtitle "Showing for ${timeout_sec}s"\'')

	// 等待 timeout（通知会在系统设置的时间后自动消失）
	time.sleep(timeout_sec * time.second)
}
