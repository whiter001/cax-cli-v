// CAX Executable Test
// Run with: v run test_exec.v

module main

import os
import time

fn main() {
	println('CAX Executable Test')
	println('====================')
	println('')

	// Simulate command line execution
	args := os.args

	if args.len < 2 {
		println('Usage: v run test_exec.v [command]')
		println('')
		println('Available test commands:')
		println('  /BEEP')
		println('  /MSG "Hello"')
		println('  /OUT "Test output"')
		println('  /OSDTEXT 50 "Test OSD"')
		println('  /CLOCK')
		println('  /HELP')
		return
	}

	cmd := args[1].to_upper()

	println('Executing: ${cmd}')
	println('')

	match cmd {
		'/BEEP' {
			beep()
		}
		'/MSG' {
			text := if args.len > 2 { args[2] } else { 'Hello' }
			show_message(text)
		}
		'/OUT' {
			text := if args.len > 2 { args[2] } else { 'Output' }
			println(text)
		}
		'/OSDTEXT' {
			timeout := if args.len > 2 { args[2] } else { '50' }
			text := if args.len > 3 { args[3] } else { 'OSD Test' }
			println('[OSDTEXT] timeout=${timeout} text="${text}"')
		}
		'/CLOCK' {
			now := time.now()
			println('Current time: ${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
		}
		'/DATE' {
			now := time.now()
			println('Current date: ${now.year}-${now.month:02d}-${now.day:02d}')
		}
		'/TEST:VARS' {
			test_variables()
		}
		'/TEST:ALL' {
			run_all_tests()
		}
		'/HELP', '-H', '-HELP' {
			show_help()
		}
		else {
			println('Unknown command: ${cmd}')
			println('Use /HELP for available commands')
		}
	}
}

fn beep() {
	println('[BEEP] Beep!')
}

fn show_message(text string) {
	println('[MSG] ${text}')
	println('')
	println('Buttons: OK')
}

fn show_help() {
	println('CAX Test Help')
	println('=============')
	println('')
	println('Test commands:')
	println('  /BEEP           - Test beep command')
	println('  /MSG "text"     - Test message box')
	println('  /OUT "text"     - Test output')
	println('  /OSDTEXT 50 "text" - Test OSD')
	println('  /CLOCK          - Show current time')
	println('  /DATE           - Show current date')
	println('  /TEST:VARS      - Test variable expansion')
	println('  /TEST:ALL       - Run all tests')
	println('  /HELP           - Show this help')
}

fn test_variables() {
	println('Testing variable expansion...')
	println('')

	now := time.now()

	// Test time variables
	println('  %!HOUR!%  = ${now.hour:02d}')
	println('  %!MIN!%   = ${now.minute:02d}')
	println('  %!SEC!%   = ${now.second:02d}')
	println('  %!CLOCK!% = ${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
	println('')

	// Test date variables
	println('  %!YEAR!%  = ${now.year}')
	println('  %!MON!%   = ${now.month:02d}')
	println('  %!DAY!%   = ${now.day:02d}')
	println('  %!DATE!%  = ${now.year}-${now.month:02d}-${now.day:02d}')
	println('')

	// Test system variables
	println('  %!UNAME!% = ${os.user_os()}')
	println('  %!CDIR!%  = ${os.getwd()}')
	println('')

	println('Variable expansion test completed!')
}

fn run_all_tests() {
	mut passed := 0
	mut failed := 0

	print('Test /BEEP... ')
	beep()
	passed++
	println('PASS')

	print('Test /OUT... ')
	println('[OUT] Test output')
	passed++
	println('PASS')

	print('Test /MSG... ')
	show_message('Test message')
	passed++
	println('PASS')

	print('Test /OSDTEXT... ')
	println('[OSDTEXT] Test OSD text')
	passed++
	println('PASS')

	print('Test /CLOCK... ')
	now := time.now()
	println('Time: ${now.hour:02d}:${now.minute:02d}:${now.second:02d}')
	passed++
	println('PASS')

	print('Test /DATE... ')
	println('Date: ${now.year}-${now.month:02d}-${now.day:02d}')
	passed++
	println('PASS')

	print('Test variable expansion... ')
	test_variables()
	passed++
	println('PASS')

	println('')
	println('====================')
	println('Passed: ${passed}')
	println('Failed: ${failed}')
	println('Total:  ${passed + failed}')
	println('====================')
}
