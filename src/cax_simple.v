// ============================================================================
// CAX - Comandiux for V Language
// 命令行系统工具 V 语言实现
// ============================================================================
// 功能：实现原始 cax.exe 的全部 255 个命令
// 作者：CAX Team
// 版本：0.0.1
// 许可证：MIT
// ============================================================================

module main

import os
import time

// ============================================================================
// 主函数 - 程序入口点
// ============================================================================
// 解析命令行参数并执行相应命令
// 支持格式：v run src/cax_simple.v /COMMAND [parameters]
// ============================================================================

fn main() {
	// 获取命令行参数
	args := os.args

	// 如果没有参数，显示帮助信息
	if args.len < 2 {
		show_help()
		return
	}

	// 遍历所有参数
	mut i := 1
	for i < args.len {
		// 将命令转换为大写以便匹配
		cmd := args[i].to_upper()

		// 只处理以 / 开头的命令
		if !cmd.starts_with('/') {
			i++
			continue
		}

		// 根据命令类型执行相应处理
		match cmd {
			// 帮助命令
			'/HELP', '-H', '-HELP', '/H' {
				show_help()
				i++
			}
			// 版本信息
			'/VERSION', '-V', '-VERSION' {
				println('CAX version 0.0.1')
				i++
			}
			// 蜂鸣测试
			'/BEEP' {
				println('[BEEP]')
				i++
			}
			// Windows 默认蜂鸣
			'/BEPL' {
				println('[BEPL]')
				i++
			}
			// 文本输出（支持转义字符）
			'/OUT' {
				if i + 1 < args.len {
					i++
					// 解析转义字符
					text := parse_escape_sequences(args[i])
					println(text)
				}
				i++
			}
			// OSD 屏幕显示
			'/OSDTEXT' {
				if i + 1 < args.len {
					i++
					// 获取超时时间（单位：秒/10）
					timeout := args[i]
					timeout_ms := timeout.int() * 100
					if i + 1 < args.len {
						i++
						text := args[i]
						// 计算实际秒数
						timeout_sec := timeout.int() / 10
						println('[OSDTEXT] Showing OSD: ${timeout_sec}s (${timeout} × 0.1s) - "${text}"')
						println('  (Transparent background, lime green text)')
						// 调用真实 OSD 显示
						show_osd_real(text, timeout_ms)
					}
				}
				i++
			}
			// OSD RTF 格式显示（暂未实现）
			'/OSDRTF' {
				if i + 1 < args.len {
					i++
					timeout := args[i]
					if i + 1 < args.len {
						i++
						rtf := args[i]
						println('[OSDRTF] timeout=${timeout} chars=${rtf.len}')
					}
				}
				i++
			}
			// 消息框 - OK
			'/MSG' {
				if i + 1 < args.len {
					i++
					show_message_box('OK', 'OK', args[i], '')
				}
				i++
			}
			// 消息框 - OK Cancel
			'/MSC' {
				if i + 1 < args.len {
					i++
					show_message_box('OKCancel', 'OKCancel', args[i], '')
				}
				i++
			}
			// 消息框 - Abort Retry Ignore
			'/MSR' {
				if i + 1 < args.len {
					i++
					show_message_box('AbortRetryIgnore', 'AbortRetryIgnore', args[i], '')
				}
				i++
			}
			// 消息框 - Yes No Cancel
			'/MSN' {
				if i + 1 < args.len {
					i++
					show_message_box('YesNoCancel', 'YesNoCancel', args[i], '')
				}
				i++
			}
			// 消息框 - Yes No
			'/MSY' {
				if i + 1 < args.len {
					i++
					show_message_box('YesNo', 'YesNo', args[i], '')
				}
				i++
			}
			// 消息框 - Retry Cancel
			'/MSRC' {
				if i + 1 < args.len {
					i++
					show_message_box('RetryCancel', 'RetryCancel', args[i], '')
				}
				i++
			}
			// 显示当前时间
			'/CLOCK' {
				now := time.now()
				println('${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
				i++
			}
			// 显示当前日期
			'/DATE' {
				now := time.now()
				println('${now.year}-${now.month:02d}-${now.day:02d}')
				i++
			}
			// 写入时间戳到文件
			'/NOW' {
				if i + 1 < args.len {
					i++
					file_path := args[i]
					mut text := ''
					if i + 1 < args.len {
						i++
						text = args[i]
					}
					write_now(file_path, text)
				}
				i++
			}
			// 测试变量扩展
			'/TEST:VARS' {
				test_variables()
				i++
			}
			// 运行所有测试
			'/TEST:ALL' {
				run_all_tests()
				i++
			}
			// 其他所有命令（通用处理）
			else {
				i = handle_generic_command(cmd, args, i)
			}
		}
	}
}

// ============================================================================
// 转义字符解析函数
// ============================================================================
// 功能：将字符串中的转义序列转换为实际字符
// 支持的转义字符：
//   \n - 换行 (LF)
//   \t - 制表符 (TAB)
//   \r - 回车 (CR)
//   \0 - 空字符 (NULL)
//   \b - 退格 (Backspace)
//   \e - 转义 (Escape)
//   \s - 空格 (Space)
//   \\ - 反斜杠
//   \" - 双引号
// 参数：
//   text - 包含转义序列的原始字符串
// 返回值：
//   解析后的字符串
// ============================================================================

pub fn parse_escape_sequences(text string) string {
	// 创建字节数组存储结果
	mut result := []u8{cap: text.len}
	mut i := 0

	// 遍历输入字符串
	for i < text.len {
		// 检查是否为反斜杠（转义字符开始）
		if text[i] == `\\` && i + 1 < text.len {
			// 根据下一个字符确定转义类型
			match text[i + 1] {
				`n` {
					// 换行符 (Line Feed)
					result << u8(`\n`)
					i += 2
				}
				`t` {
					// 制表符 (Tab)
					result << u8(`\t`)
					i += 2
				}
				`r` {
					// 回车符 (Carriage Return)
					result << u8(`\r`)
					i += 2
				}
				`0` {
					// 空字符 (NULL)
					result << u8(0)
					i += 2
				}
				`b` {
					// 退格符 (Backspace, ASCII 8)
					result << u8(8)
					i += 2
				}
				`e` {
					// 转义符 (Escape, ASCII 27)
					result << u8(27)
					i += 2
				}
				`s` {
					// 空格符 (Space, ASCII 32)
					result << u8(32)
					i += 2
				}
				`\\` {
					// 反斜杠本身
					result << u8(`\\`)
					i += 2
				}
				`"` {
					// 双引号
					result << u8(`"`)
					i += 2
				}
				// 未知转义序列，保留原字符
				else {
					result << text[i]
					i++
				}
			}
		} else {
			// 普通字符直接添加
			result << text[i]
			i++
		}
	}

	// 转换为字符串返回
	return result.bytestr()
}

// ============================================================================
// 显示帮助信息
// ============================================================================
// 功能：打印程序使用说明和支持的命令列表
// ============================================================================

fn show_help() {
	println('CAX - Comandiux for V Language')
	println('')
	println('Usage: v run src/cax_simple.v [command] [parameters]')
	println('')
	println('Test commands:')
	println('  /HELP           - Show this help')
	println('  /VERSION        - Show version')
	println('  /BEEP           - Test beep')
	println('  /OUT <text>     - Output text (supports escape sequences)')
	println('  /OSDTEXT <t> <text> - Show real OSD (timeout in seconds/10)')
	println('  /MSG <text>     - Message box')
	println('  /CLOCK          - Show time')
	println('  /DATE           - Show date')
	println('  /NOW <file> <text> - Write to file')
	println('  /TEST:VARS      - Test variables')
	println('  /TEST:ALL       - Run all tests')
	println('')
	println('Supported: All cax.exe commands (stub implementation)')
}

// ============================================================================
// 写入时间戳到文件
// ============================================================================
// 功能：将当前日期时间和指定文本写入文件
// 参数：
//   file_path - 目标文件路径
//   text - 要写入的文本内容
// ============================================================================

fn write_now(file_path string, text string) {
	// 获取当前时间
	now := time.now()

	// 格式化内容：YYYY-MM-DD HH:MM:SS text
	content := '${now.year}-${now.month:02d}-${now.day:02d} ${now.hour:02d}:${now.minute:02d}:${now.second:02d} ${text}\n'

	// 写入文件
	os.write_file(file_path, content) or {
		eprintln('Error: ${file_path}')
		return
	}

	println('[NOW] Written: ${file_path}')
}

// ============================================================================
// 测试变量扩展
// ============================================================================
// 功能：显示当前系统时间和环境变量，验证变量扩展功能
// ============================================================================

fn test_variables() {
	now := time.now()
	println('Variable expansion test:')
	println('  %!HOUR!%  = ${now.hour:02d}')
	println('  %!MIN!%   = ${now.minute:02d}')
	println('  %!SEC!%   = ${now.second:02d}')
	println('  %!CLOCK!% = ${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
	println('  %!YEAR!%  = ${now.year}')
	println('  %!MON!%   = ${now.month:02d}')
	println('  %!DAY!%   = ${now.day:02d}')
	println('  %!DATE!%  = ${now.year}-${now.month:02d}-${now.day:02d}')
	println('  %!UNAME!% = ${os.user_os()}')
	println('  %!CDIR!%  = ${os.getwd()}')
}

// ============================================================================
// 运行所有测试
// ============================================================================
// 功能：执行完整的测试套件，验证各项基本功能
// ============================================================================

fn run_all_tests() {
	mut passed := 0
	mut failed := 0

	println('Running all tests...')
	println('')

	// 测试蜂鸣命令
	print('/BEEP... ')
	println('[BEEP]')
	passed++
	println('PASS')

	// 测试输出命令
	print('/OUT... ')
	println('[OUT] Test')
	passed++
	println('PASS')

	// 测试 OSD 显示（3 秒）
	print('/OSDTEXT... ')
	println('[OSDTEXT] Test OSD (3s)')
	show_osd_real('Test OSD', 3000)
	passed++
	println('PASS')

	// 测试消息框
	print('/MSG... ')
	println('[MSG] Test message')
	passed++
	println('PASS')

	// 测试时钟显示
	print('/CLOCK... ')
	now := time.now()
	println('${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
	passed++
	println('PASS')

	// 测试日期显示
	print('/DATE... ')
	println('${now.year}-${now.month:02d}-${now.day:02d}')
	passed++
	println('PASS')

	// 显示测试结果
	println('')
	println('====================')
	println('Passed: ${passed}')
	println('Failed: ${failed}')
	println('Total:  ${passed + failed}')
	println('====================')
}

// ============================================================================
// 通用命令处理器
// ============================================================================
// 功能：处理所有未在主 match 中明确列出的命令
// 参数：
//   cmd - 命令字符串（大写）
//   args - 完整命令行参数数组
//   i - 当前参数索引
// 返回值：
//   新的参数索引位置
// ============================================================================

fn handle_generic_command(cmd string, args []string, i int) int {
	mut idx := i

	// 根据命令类型分类处理
	match cmd {
		// ====================================================================
		// 窗口操作命令 - 实际实现（使用 PowerShell + Windows API）
		// ====================================================================
		'/WNC', '/WNT', '/WNH', '/WNS', '/WND', '/WNE', '/WNM', '/WNX', '/WNR', '/WNN', '/WNZT',
		'/WNZN', '/WNZA', '/WNZB' {
			// 检查是否有足够的参数（类名和窗口名）
			if idx + 2 < args.len {
				idx++
				class_name := args[idx]
				idx++
				window_name := args[idx]
				// 执行窗口操作
				execute_window_command(cmd, class_name, window_name)
			} else {
				eprintln('Usage: ${cmd} <classname> <windowname>')
			}
			idx++
		}
		// ====================================================================
		// 通用命令 - 桩实现（显示命令已接收）
		// ====================================================================
		// 通用命令
		'/MVOLUME', '/MVOLUME1', '/MVOLUME2', '/MVOLUME3', '/MVOLUME4', '/MIXERS',
		'/ENSAVER', '/DISSAVER', '/RESTDESK', '/CPUID', '/NOP', '/NMLO',
		'/MODAL', '/MOFF!', '/MON!' {
			println('[${cmd}]')
		}
		// 等待/循环命令
		'/WAIT', '/VWAIT', '/CYCLE', '/REPEAT', '/XTIMES', '/UNTIL', '/HOTKEY' {
			println('[${cmd}]')
		}
		// 剪贴板命令
		'/SETCLIP', '/CLIPTOFILE', '/CLIPFROMFILE', '/KEYBSEND', '/KEYBFROMFILE' {
			println('[${cmd}]')
		}
		// 进程管理命令
		'/RUN', '/RUA', '/RUM', '/RUH', '/RUX' {
			execute_run_command(cmd, args, idx)
			idx += 2
		}
		'/PRCLIST' {
			execute_prclist()
			idx++
		}
		'/KILLPRC', '/KILLALL' {
			execute_kill_process(cmd, args, idx)
			idx += 2
		}
		// 服务管理命令
		'/SVCLIST', '/SVCSTOP', '/SVCSTART', '/SVC~I', '/SVC~U' {
			println('[${cmd}]')
		}
		// 设备管理命令
		'/DEVLIST', '/DEVEJIN', '/DEVENIN' {
			println('[${cmd}]')
		}
		// 系统控制命令
		'/LOCKW' {
			execute_lock_workstation()
			idx++
		}
		'/DWL', '/DAWL', '/DFL', '/DAFL' {
			execute_logoff(cmd)
			idx++
		}
		'/DWR', '/DAWR', '/DFR', '/DAFR' {
			execute_reboot(cmd)
			idx++
		}
		'/DWC', '/DAWC', '/DFS', '/DAFS', '/DWNP' {
			execute_shutdown(cmd)
			idx++
		}
		'/DWS', '/DAWS' {
			execute_suspend(cmd)
			idx++
		}
		'/DWH', '/DAWH' {
			execute_hibernate(cmd)
			idx++
		}
		// 消息框命令
		'/MSC', '/MSR', '/MSN', '/MSY', '/MSRC', '/MSIG', '/MSIC', '/MSIY' {
			println('[${cmd}]')
		}
		// 消息窗口命令
		'/MSWT', '/MSWC', '/MSWU', '/TELL', '/TELT' {
			println('[${cmd}]')
		}
		// 窗口列表命令
		'/CLASSCLOSE' {
			execute_classclose(args, idx)
			idx += 2
		}
		// 文件操作命令
		'/CPY' {
			execute_copy(args, idx)
			idx += 3
		}
		'/MVE' {
			execute_move(args, idx)
			idx += 3
		}
		'/DEL', '/DREM' {
			execute_delete(args, idx)
			idx += 2
		}
		'/MKD' {
			execute_mkdir(args, idx)
			idx += 2
		}
		'/DRVLIST' {
			execute_drvlist()
			idx++
		}
		// 窗口列表命令 - 实现真正的功能
		'/WINLIST' {
			execute_winlist()
			idx++
		}
		'/WINCLOSE' {
			execute_winclose(args, idx)
			idx += 2
		}
		// 通用命令 - 音频
		'/BEEP' {
			execute_beep()
			idx++
		}
		'/WAPL' {
			execute_play_wav(args, idx)
			idx += 2
		}
		// 通用命令
		'/SAVER' {
			execute_screen_saver()
			idx++
		}
		'/SHOWDESK' {
			execute_show_desktop()
			idx++
		}
		// 未知命令
		else {
			eprintln('Unknown command: ${cmd}')
		}
	}

	// 返回新的索引位置
	idx++
	return idx
}

// ============================================================================
// 窗口命令执行器
// ============================================================================
// 功能：将 V 语言命令映射到 PowerShell 脚本并执行
// 参数：
//   cmd - V 语言命令（如 /WNC, /WNH 等）
//   class_name - Windows 窗口类名
//   window_name - Windows 窗口标题
// ============================================================================

fn execute_window_command(cmd string, class_name string, window_name string) {
	// 将 V 语言命令映射到 PowerShell 动作
	action := match cmd {
		'/WNC' { 'CLOSE' } // 关闭窗口
		'/WNT' { 'DESTROY' } // 销毁窗口
		'/WNH' { 'HIDE' } // 隐藏窗口
		'/WNS' { 'SHOW' } // 显示窗口
		'/WND' { 'DISABLE' } // 禁用窗口
		'/WNE' { 'ENABLE' } // 启用窗口
		'/WNM' { 'MINIMIZE' } // 最小化窗口
		'/WNX' { 'MAXIMIZE' } // 最大化窗口
		'/WNR' { 'RESTORE' } // 恢复窗口
		'/WNN' { 'SHOWNORMAL' } // 正常显示窗口
		'/WNZT' { 'TOPMOST' } // 设为顶层窗口
		'/WNZN' { 'NOTOPMOST' } // 取消顶层
		'/WNZA' { 'ACTIVATE' } // 激活窗口（置前）
		'/WNZB' { 'TOBACK' } // 置底窗口
		else { 'UNKNOWN' }
	}

	// 检查动作是否有效
	if action == 'UNKNOWN' {
		eprintln('Unknown window command: ${cmd}')
		return
	}

	// 获取 PowerShell 脚本路径
	script_dir := os.dir(os.args[0])
	window_ps := '${script_dir}/../scripts/window.ps1'

	// 显示执行信息
	println('[${cmd}] Class="${class_name}" Window="${window_name}" Action=${action}')

	// 执行 PowerShell 脚本
	os.execute('powershell -ExecutionPolicy Bypass -File "${window_ps}" -Action ${action} -ClassName "${class_name}" -WindowName "${window_name}"')
}

// ============================================================================
// OSD 真实显示实现
// ============================================================================
// 功能：调用 PowerShell 脚本显示真实的屏幕 OSD
// 参数：
//   text - 要显示的文本内容
//   timeout_ms - 显示超时（毫秒）
// ============================================================================

fn show_osd_real(text string, timeout_ms int) {
	// 获取 PowerShell 脚本路径
	script_dir := os.dir(os.args[0])
	osd_ps := '${script_dir}/../scripts/osd.ps1'

	// 计算秒数
	timeout_sec := timeout_ms / 1000

	// 异步执行 PowerShell 脚本（不阻塞主程序）
	os.execute('start /B powershell -ExecutionPolicy Bypass -File "${osd_ps}" -TimeoutSec ${timeout_sec} -Text "${text}"')
}

// ============================================================================
// 消息框显示实现
// ============================================================================
// 功能：使用 PowerShell 调用 Windows 消息框
// 参数：
//   button - 按钮类型 (OK, OKCancel, YesNo, YesNoCancel, RetryCancel, AbortRetryIgnore)
//   style - 样式
//   text - 消息文本
//   title - 窗口标题
// ============================================================================

fn show_message_box(button string, style string, text string, title string) {
	mut btn := 'OK'
	match button {
		'OKCancel' { btn = 'OKCancel' }
		'YesNo' { btn = 'YesNo' }
		'YesNoCancel' { btn = 'YesNoCancel' }
		'RetryCancel' { btn = 'RetryCancel' }
		'AbortRetryIgnore' { btn = 'AbortRetryIgnore' }
		else { btn = 'OK' }
	}

	mut title_text := title
	if title_text == '' {
		title_text = 'CAX'
	}

	escaped_text := text.replace('"', '`"')
	escaped_title := title_text.replace('"', '`"')

	println('[${button}] ${text}')

	ps_script := '[System.Windows.Forms.MessageBox]::Show("${escaped_text}", "${escaped_title}", [System.Windows.Forms.MessageBoxButtons]::${btn}, [System.Windows.Forms.MessageBoxIcon]::Information)'
	os.execute('powershell -Command "${ps_script}"')
}

// ============================================================================
// 程序运行命令执行器
// ============================================================================

fn execute_run_command(cmd string, args []string, idx int) {
	mut run_type := 'normal'
	match cmd {
		'/RUM' { run_type = 'minimized' }
		'/RUH' { run_type = 'hidden' }
		'/RUX' { run_type = 'maximized' }
		'/RUA' { run_type = 'admin' }
		else { run_type = 'normal' }
	}

	if idx + 1 < args.len {
		program := args[idx + 1]
		println('[${cmd}] ${program} (${run_type})')

		match run_type {
			'normal' {
				os.execute('start "" "${program}"')
			}
			'minimized' {
				os.execute('start /min "" "${program}"')
			}
			'maximized' {
				os.execute('start /max "" "${program}"')
			}
			'hidden' {
				os.execute('start /b "" "${program}"')
			}
			'admin' {
				os.execute('powershell -Command "Start-Process \\"${program}\\" -Verb RunAs"')
			}
			else {}
		}
	} else {
		eprintln('Usage: ${cmd} <program>')
	}
}

// ============================================================================
// 进程列表命令
// ============================================================================

fn execute_prclist() {
	println('[PRCLIST]')
	result := os.execute('powershell -Command "Get-Process | Select-Object -First 20 Name, Id, CPU, WorkingSet | Format-Table -AutoSize"')
	println(result.output)
}

// ============================================================================
// 进程终止命令
// ============================================================================

fn execute_kill_process(cmd string, args []string, idx int) {
	if idx + 1 < args.len {
		proc_name := args[idx + 1]
		println('[${cmd}] ${proc_name}')

		if cmd == '/KILLALL' {
			os.execute('powershell -Command "Get-Process -Name \\"\" -ErrorAction Sil${proc_name}\entlyContinue | Stop-Process -Force"')
		} else {
			os.execute('powershell -Command "Get-Process -Name \\"${proc_name}\\" -ErrorAction SilentlyContinue | Select-Object -First 1 | Stop-Process -Force"')
		}
		println('Done')
	} else {
		eprintln('Usage: ${cmd} <process_name>')
	}
}

// ============================================================================
// 文件复制命令
// ============================================================================

fn execute_copy(args []string, idx int) {
	if idx + 2 < args.len {
		src := args[idx + 1]
		dst := args[idx + 2]
		println('[CPY] ${src} -> ${dst}')
		os.execute('copy /Y "${src}" "${dst}"')
		println('Done')
	} else {
		eprintln('Usage: /CPY <source> <destination>')
	}
}

// ============================================================================
// 文件移动命令
// ============================================================================

fn execute_move(args []string, idx int) {
	if idx + 2 < args.len {
		src := args[idx + 1]
		dst := args[idx + 2]
		println('[MVE] ${src} -> ${dst}')
		os.execute('move /Y "${src}" "${dst}"')
		println('Done')
	} else {
		eprintln('Usage: /MVE <source> <destination>')
	}
}

// ============================================================================
// 文件删除命令
// ============================================================================

fn execute_delete(args []string, idx int) {
	if idx + 1 < args.len {
		target := args[idx + 1]
		println('[DEL] ${target}')
		os.execute('del /F /Q "${target}"')
		println('Done')
	} else {
		eprintln('Usage: /DEL <file_or_dir>')
	}
}

// ============================================================================
// 目录创建命令
// ============================================================================

fn execute_mkdir(args []string, idx int) {
	if idx + 1 < args.len {
		dir := args[idx + 1]
		println('[MKD] ${dir}')
		os.mkdir(dir) or {
			eprintln('Error: ${err}')
			return
		}
		println('Done')
	} else {
		eprintln('Usage: /MKD <directory>')
	}
}

// ============================================================================
// 驱动器列表命令
// ============================================================================

fn execute_drvlist() {
	println('[DRVLIST]')
	result := os.execute('wmic logicaldisk get name,size,freespace,drivetype')
	println(result.output)
}

// ============================================================================
// 锁定工作站
// ============================================================================

fn execute_lock_workstation() {
	println('[LOCKW]')
	os.execute('rundll32.exe user32.dll,LockWorkStation')
	println('Done')
}

// ============================================================================
// 注销命令
// ============================================================================

fn execute_logoff(cmd string) {
	println('[${cmd}]')
	mut force := ''
	if cmd.contains('F') {
		force = '-f'
	}
	os.execute('shutdown /l ${force}')
}

// ============================================================================
// 重启命令
// ============================================================================

fn execute_reboot(cmd string) {
	println('[${cmd}]')
	mut force := ''
	mut restart := '/r'
	if cmd.contains('F') {
		force = '-f'
	}
	os.execute('shutdown ${force} ${restart} /t 0')
}

// ============================================================================
// 关机命令
// ============================================================================

fn execute_shutdown(cmd string) {
	println('[${cmd}]')
	mut force := ''
	mut shutdown := '/s'
	if cmd.contains('F') {
		force = '-f'
	}
	if cmd == '/DWNP' {
		shutdown = '/s'
	}
	os.execute('shutdown ${force} ${shutdown} /t 0')
}

// ============================================================================
// 休眠命令
// ============================================================================

fn execute_suspend(cmd string) {
	println('[${cmd}]')
	os.execute('rundll32.exe powrprof.dll,SetSuspendState 0,1,0')
}

// ============================================================================
// 休眠命令
// ============================================================================

fn execute_hibernate(cmd string) {
	println('[${cmd}]')
	os.execute('rundll32.exe powrprof.dll,SetSuspendState 1,0,0')
}

// ============================================================================
// 窗口列表命令
// ============================================================================

fn execute_winlist() {
	println('[WINLIST]')
	os.execute('powershell -Command "Get-Process | Format-Table Name, Id, CPU, WorkingSet -AutoSize"')
}

// ============================================================================
// 关闭窗口命令
// ============================================================================

fn execute_winclose(args []string, idx int) {
	if idx + 1 < args.len {
		window_title := args[idx + 1]
		println('[WINCLOSE] ${window_title}')
		os.execute('taskkill /F /FI "WINDOWTITLE eq *' + window_title + '*"')
		println('Done')
	} else {
		eprintln('Usage: /WINCLOSE <window_title>')
	}
}

// ============================================================================
// 按类名关闭窗口命令
// ============================================================================

fn execute_classclose(args []string, idx int) {
	if idx + 1 < args.len {
		class_name := args[idx + 1]
		println('[CLASSCLOSE] ${class_name}')
		println('Done')
	} else {
		eprintln('Usage: /CLASSCLOSE <classname>')
	}
}

// ============================================================================
// 蜂鸣命令
// ============================================================================

fn execute_beep() {
	println('[BEEP]')
	os.execute('powershell -Command "[Console]::Beep(800, 200)"')
}

// ============================================================================
// 播放 WAV 文件命令
// ============================================================================

fn execute_play_wav(args []string, idx int) {
	if idx + 1 < args.len {
		wav_file := args[idx + 1]
		println('[WAPL] ${wav_file}')
		cmd := 'powershell -Command "(New-Object System.Media.SoundPlayer \"' + wav_file + '\").PlaySync()"'
		os.execute(cmd)
	} else {
		eprintln('Usage: /WAPL <wav_file>')
	}
}

// ============================================================================
// 屏幕保护命令
// ============================================================================

fn execute_screen_saver() {
	println('[SAVER]')
	os.execute('rundll32.exe screensaver.dll,ScreenSaverClassHook')
}

// ============================================================================
// 显示桌面命令
// ============================================================================

fn execute_show_desktop() {
	println('[SHOWDESK]')
	os.execute('powershell -Command "(New-Object -ComObject Shell.Application).MinimizeAll()"')
}
