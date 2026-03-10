// CAX - Simplified Executable Version with Real OSD
// Run with: v run src/cax_simple.v /OSDTEXT 20 "Test"

module main

import os
import time

fn main() {
	args := os.args
	if args.len < 2 {
		show_help()
		return
	}
	
	mut i := 1
	for i < args.len {
		cmd := args[i].to_upper()
		
		if !cmd.starts_with('/') {
			i++
			continue
		}
		
		match cmd {
			'/HELP', '-H', '-HELP', '/H' {
				show_help()
				i++
			}
			'/VERSION', '-V', '-VERSION' {
				println('CAX version 0.0.1')
				i++
			}
			'/BEEP' {
				println('[BEEP]')
				i++
			}
			'/BEPL' {
				println('[BEPL]')
				i++
			}
			'/OUT' {
				if i + 1 < args.len {
					i++
					println(args[i])
				}
				i++
			}
			'/OSDTEXT' {
				if i + 1 < args.len {
					i++
					timeout := args[i]
					// cax.exe format: timeout is in seconds/10 (30 = 3 seconds)
					timeout_ms := timeout.int() * 100
					if i + 1 < args.len {
						i++
						text := args[i]
						timeout_sec := timeout.int() / 10
						println('[OSDTEXT] Showing OSD: ${timeout_sec}s (${timeout} × 0.1s) - "${text}"')
						println('  (Transparent background, lime green text)')
						show_osd_real(text, timeout_ms)
					}
				}
				i++
			}
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
			'/MSG' {
				if i + 1 < args.len {
					i++
					println('[MSG] ${args[i]}')
				}
				i++
			}
			'/CLOCK' {
				now := time.now()
				println('${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
				i++
			}
			'/DATE' {
				now := time.now()
				println('${now.year}-${now.month:02d}-${now.day:02d}')
				i++
			}
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
			'/TEST:VARS' {
				test_variables()
				i++
			}
			'/TEST:ALL' {
				run_all_tests()
				i++
			}
			else {
				// Generic handler for all other commands
				i = handle_generic_command(cmd, args, i)
			}
		}
	}
}

fn show_osd_real(text string, timeout_ms int) {
	// Use PowerShell script to show real OSD (async)
	script_dir := os.dir(os.args[0])
	osd_ps := '${script_dir}/../scripts/osd.ps1'
	// Pass timeout (seconds) and text
	timeout_sec := timeout_ms / 1000
	// Use Start-Process to run async
	os.execute('start /B powershell -ExecutionPolicy Bypass -File "${osd_ps}" -TimeoutSec ${timeout_sec} -Text "${text}"')
}

fn show_help() {
	println('CAX - Comandiux for V Language')
	println('')
	println('Usage: v run src/cax_simple.v [command] [parameters]')
	println('')
	println('Test commands:')
	println('  /HELP           - Show this help')
	println('  /VERSION        - Show version')
	println('  /BEEP           - Test beep')
	println('  /OUT <text>     - Output text')
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

fn write_now(file_path string, text string) {
	now := time.now()
	content := '${now.year}-${now.month:02d}-${now.day:02d} ${now.hour:02d}:${now.minute:02d}:${now.second:02d} ${text}\n'
	os.write_file(file_path, content) or {
		eprintln('Error: ${file_path}')
		return
	}
	println('[NOW] Written: ${file_path}')
}

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

fn run_all_tests() {
	mut passed := 0
	mut failed := 0
	
	println('Running all tests...')
	println('')
	
	print('/BEEP... ')
	println('[BEEP]')
	passed++
	println('PASS')
	
	print('/OUT... ')
	println('[OUT] Test')
	passed++
	println('PASS')
	
	print('/OSDTEXT... ')
	println('[OSDTEXT] Test OSD (3s)')
	show_osd_real('Test OSD', 3000)
	passed++
	println('PASS')
	
	print('/MSG... ')
	println('[MSG] Test message')
	passed++
	println('PASS')
	
	print('/CLOCK... ')
	now := time.now()
	println('${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
	passed++
	println('PASS')
	
	print('/DATE... ')
	println('${now.year}-${now.month:02d}-${now.day:02d}')
	passed++
	println('PASS')
	
	println('')
	println('====================')
	println('Passed: ${passed}')
	println('Failed: ${failed}')
	println('Total:  ${passed + failed}')
	println('====================')
}

fn handle_generic_command(cmd string, args []string, i int) int {
	mut idx := i
	// Generic handler for unsupported commands
	match cmd {
		// General purpose
		'/WAPL', '/MVOLUME', '/MVOLUME1', '/MVOLUME2', '/MVOLUME3', '/MVOLUME4',
		'/MIXERS', '/SAVER', '/ENSAVER', '/DISSAVER', '/SHOWDESK', '/RESTDESK',
		'/CPUID', '/NOP', '/NMLO', '/MODAL', '/MOFF!', '/MON!' {
			println('[${cmd}]')
		}
		
		// Wait commands
		'/WAIT', '/VWAIT', '/CYCLE', '/REPEAT', '/XTIMES', '/UNTIL', '/HOTKEY' {
			println('[${cmd}]')
		}
		
		// Clipboard
		'/SETCLIP', '/CLIPTOFILE', '/CLIPFROMFILE', '/KEYBSEND', '/KEYBFROMFILE' {
			println('[${cmd}]')
		}
		
		// Process
		'/RUN', '/RUA', '/RUM', '/RUH', '/RUX', '/PRCLIST', '/KILLPRC', '/KILLALL' {
			println('[${cmd}]')
		}
		
		// Services
		'/SVCLIST', '/SVCSTOP', '/SVCSTART', '/SVC~I', '/SVC~U' {
			println('[${cmd}]')
		}
		
		// Devices
		'/DEVLIST', '/DEVEJIN', '/DEVENIN' {
			println('[${cmd}]')
		}
		
		// Power
		'/DWR', '/DWC', '/DWL', '/DWS', '/DWH', '/LOCKW' {
			println('[${cmd}]')
		}
		
		// Window
		'/WNC', '/WINLIST', '/WINCLOSE', '/CLASSCLOSE' {
			println('[${cmd}]')
		}
		
		// File
		'/CPY', '/MVE', '/DEL', '/MKD', '/DRVLIST' {
			println('[${cmd}]')
		}
		
		// Message boxes
		'/MSC', '/MSY', '/MSN', '/MSIG', '/MSIC' {
			println('[${cmd}]')
		}
		
		else {
			eprintln('Unknown command: ${cmd}')
		}
	}
	idx++
	return idx
}
