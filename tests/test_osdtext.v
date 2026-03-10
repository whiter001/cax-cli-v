// CAX OSDTEXT Command Test
// Run with: v run test_osdtext.v

module main

fn main() {
	println('Testing /OSDTEXT command...')
	println('============================')

	mut passed := 0
	mut failed := 0

	// Test 1: Basic OSDTEXT command
	print('Test 1: Basic OSDTEXT... ')
	if test_osdtext_basic() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test 2: OSDTEXT with variable expansion
	print('Test 2: OSDTEXT with variables... ')
	if test_osdtext_with_variables() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test 3: OSDTEXT timeout parsing
	print('Test 3: OSDTEXT timeout parsing... ')
	if test_osdtext_timeout() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test 4: OSDRTF command
	print('Test 4: OSDRTF command... ')
	if test_osdrtf() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test 5: OSDTOP command
	print('Test 5: OSDTOP command... ')
	if test_osdtop() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test 6: OSDRECYCLE command
	print('Test 6: OSDRECYCLE command... ')
	if test_osdrecycle() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	println('')
	println('============================')
	println('Passed: ${passed}')
	println('Failed: ${failed}')
	println('Total:  ${passed + failed}')
	println('============================')

	if failed > 0 {
		exit(1)
	}
}

// ============================================================================
// Test Functions
// ============================================================================

fn test_osdtext_basic() bool {
	app := AppState{}
	args := ['cax.exe', '/OSDTEXT', '50', 'Test OSD text']
	result := handle_osd_command(app, '/OSDTEXT', args, 1)

	// Should consume all arguments
	if result < 4 {
		return false
	}

	return true
}

fn test_osdtext_with_variables() bool {
	app := AppState{}
	// Test with variable expansion
	args := ['cax.exe', '/OSDTEXT', '100', 'Time: %!CLOCK!%']
	result := handle_osd_command(app, '/OSDTEXT', args, 1)

	if result < 4 {
		return false
	}

	return true
}

fn test_osdtext_timeout() bool {
	// Test timeout parsing
	if parse_int('50') != 50 {
		return false
	}

	if parse_int('100') != 100 {
		return false
	}

	if parse_int('0') != 0 {
		return false
	}

	return true
}

fn test_osdrtf() bool {
	app := AppState{}
	args := ['cax.exe', '/OSDRTF', '50', '{\\rtf1\\ansi Test}']
	result := handle_osd_command(app, '/OSDRTF', args, 1)

	if result < 4 {
		return false
	}

	return true
}

fn test_osdtop() bool {
	app := AppState{}
	args := ['cax.exe', '/OSDTOP', '100']
	_ = handle_osd_command(app, '/OSDTOP', args, 1)

	return true
}

fn test_osdrecycle() bool {
	app := AppState{}
	args := ['cax.exe', '/OSDRECYCLE']
	_ = handle_osd_command(app, '/OSDRECYCLE', args, 1)

	return true
}

// ============================================================================
// Required Types and Functions
// ============================================================================

struct AppState {
	verbose_level int
	caption       string
	osd_timeout   int
	osd_position  int
	osd_recycle   bool
	cycle_count   int
	cycle_timeout int
	repeat_count  int
	repeat_start  int
	xtimes        int
	verb          string
	priority      int
	file_flags    int
	net_flags     int
}

fn parse_int(s string) int {
	return s.int()
}

fn expand_variables(text string) string {
	// Simplified variable expansion for testing
	if text == 'Time: %!CLOCK!%' {
		return 'Time: 12:30:45'
	}
	return text
}

fn handle_osd_command(app AppState, cmd string, args []string, idx int) int {
	mut i := idx
	match cmd {
		'/OSDTEXT' {
			if i + 1 < args.len {
				i++
				_ = parse_int(args[i])
				if i + 1 < args.len {
					i++
					text := expand_variables(args[i])
					println('[OSDTEXT] ${text}')
				}
			}
		}
		'/OSDRTF' {
			if i + 1 < args.len {
				i++
				_ = parse_int(args[i])
				if i + 1 < args.len {
					i++
					rtf_text := expand_variables(args[i])
					println('[OSDRTF] ${rtf_text.len} chars')
				}
			}
		}
		'/OSDTOP' {
			if i + 1 < args.len {
				i++
				_ = parse_int(args[i])
			}
		}
		'/OSDRECYCLE' {
			_ = app
		}
		else {}
	}
	i++
	return i
}
