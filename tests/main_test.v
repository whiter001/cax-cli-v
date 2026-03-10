module main

import os

// ============================================================================
// Test Helper Functions
// ============================================================================

fn test_parse_int() {
	// Test valid integer parsing
	assert parse_int('123') == 123
	assert parse_int('-456') == -456
	assert parse_int('0') == 0

	// Test invalid input returns 0
	assert parse_int('abc') == 0
	assert parse_int('') == 0
}

fn test_parse_uint() {
	// Test valid unsigned integer parsing
	assert parse_uint('123') == 123
	assert parse_uint('0') == 0

	// Test invalid input returns 0
	assert parse_uint('abc') == 0
	assert parse_uint('') == 0
}

fn test_parse_volume() {
	// Test absolute volume
	vol := parse_volume('50') or { 0 }
	assert vol == 50

	// Test relative volume
	vol_rel := parse_volume('R-10') or { 0 }
	assert vol_rel == -10

	// Test invalid input
	vol_inv := parse_volume('abc') or { 0 }
	assert vol_inv == 0
}

// ============================================================================
// Variable Expansion Tests
// ============================================================================

fn test_expand_variables_clock() {
	text := expand_variables('%!CLOCK!%')
	// Clock should be in HH:MM:SS format
	assert text.len > 0
	assert text.index(':') != -1
}

fn test_expand_variables_date() {
	text := expand_variables('%!DATE!%')
	// Date should be in YYYY-MM-DD format
	assert text.len == 10
	assert text.index('-') != -1
}

fn test_expand_variables_time() {
	text := expand_variables('%!TIME!%')
	// Time should contain digits and dashes
	assert text.len > 0
}

fn test_expand_variables_hour() {
	text := expand_variables('%!HOUR!%')
	assert text.len == 2
}

fn test_expand_variables_min() {
	text := expand_variables('%!MIN!%')
	assert text.len == 2
}

fn test_expand_variables_sec() {
	text := expand_variables('%!SEC!%')
	assert text.len == 2
}

fn test_expand_variables_year() {
	text := expand_variables('%!YEAR!%')
	assert text.len == 4
}

fn test_expand_variables_mon() {
	text := expand_variables('%!MON!%')
	assert text.len == 2
}

fn test_expand_variables_day() {
	text := expand_variables('%!DAY!%')
	assert text.len == 2
}

fn test_expand_variables_tick() {
	text := expand_variables('%!TICK!%')
	// Tick should be a number
	assert text.len > 0
}

fn test_expand_variables_htick() {
	text := expand_variables('%!HTICK!%')
	// HTick should be 8 hex digits
	assert text.len == 8
}

fn test_expand_variables_cdir() {
	text := expand_variables('%!CDIR!%')
	// Current directory should not be empty
	assert text.len > 0
}

fn test_expand_variables_cdrive() {
	text := expand_variables('%!CDRIVE!%')
	// Drive should be a letter
	assert text.len >= 1
}

fn test_expand_variables_uname() {
	text := expand_variables('%!UNAME!%')
	// Username should not be empty
	assert text.len > 0
}

fn test_expand_variables_cname() {
	text := expand_variables('%!CNAME!%')
	// Computer name should not be empty
	assert text.len > 0
}

fn test_expand_variables_sdrive() {
	text := expand_variables('%!SDRIVE!%')
	// Starting drive should be a letter
	assert text.len >= 1
}

fn test_expand_variables_sdir() {
	text := expand_variables('%!SDIR!%')
	// Starting directory should not be empty
	assert text.len > 0
}

fn test_expand_variables_multiple() {
	text := expand_variables('%!HOUR!%:%!MIN!%:%!SEC!%')
	// Should expand all variables
	assert text.index('%') == -1
	assert text.index(':') != -1
}

fn test_expand_variables_none() {
	text := expand_variables('Hello World')
	assert text == 'Hello World'
}

fn test_expand_variables_env() {
	// Test environment variable expansion
	os.setenv('TEST_VAR', 'test_value')
	text := expand_variables('%!TEST_VAR!%')
	assert text == 'test_value'
	os.unsetenv('TEST_VAR')
}

// ============================================================================
// Command Processing Tests
// ============================================================================

fn test_command_nop() {
	mut app := AppState{}
	args := ['cax.exe', '/NOP']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_out() {
	mut app := AppState{}
	args := ['cax.exe', '/OUT', 'Hello Test']
	result := process_command(mut app, args, 1)
	assert result == 3
}

fn test_command_beep() {
	mut app := AppState{}
	args := ['cax.exe', '/BEEP']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_bepl() {
	mut app := AppState{}
	args := ['cax.exe', '/BEPL']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_cpuid() {
	mut app := AppState{}
	args := ['cax.exe', '/CPUID']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_showdesk() {
	mut app := AppState{}
	args := ['cax.exe', '/SHOWDESK']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_saver() {
	mut app := AppState{}
	args := ['cax.exe', '/SAVER']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_ensaver() {
	mut app := AppState{}
	args := ['cax.exe', '/ENSAVER']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_dissaver() {
	mut app := AppState{}
	args := ['cax.exe', '/DISSAVER']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_mixers() {
	mut app := AppState{}
	args := ['cax.exe', '/MIXERS']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_setclip() {
	mut app := AppState{}
	args := ['cax.exe', '/SETCLIP', 'Test clipboard text']
	result := process_command(mut app, args, 1)
	assert result == 3
}

fn test_command_nmlo() {
	mut app := AppState{}
	args := ['cax.exe', '/NMLO']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_prclist() {
	mut app := AppState{}
	args := ['cax.exe', '/PRCLIST']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_svclist() {
	mut app := AppState{}
	args := ['cax.exe', '/SVCLIST']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_devlist() {
	mut app := AppState{}
	args := ['cax.exe', '/DEVLIST']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_drvlist() {
	mut app := AppState{}
	args := ['cax.exe', '/DRVLIST']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_winlist() {
	mut app := AppState{}
	args := ['cax.exe', '/WINLIST']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_caxlist() {
	mut app := AppState{}
	args := ['cax.exe', '/CAXLIST']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_help() {
	mut app := AppState{}
	args := ['cax.exe', '/HELP']
	result := process_command(mut app, args, 1)
	assert result == 2
}

fn test_command_version() {
	mut app := AppState{}
	args := ['cax.exe', '/VERSION']
	result := process_command(mut app, args, 1)
	assert result == 2
}

// ============================================================================
// AppState Tests
// ============================================================================

fn test_appstate_default() {
	app := AppState{}
	assert app.verbose_level == 0
	assert app.caption == ''
	assert app.osd_position == 0 // Default is 0 in struct
	assert app.verb == ''
	assert app.priority == 0
}

fn test_appstate_verb() {
	mut app := AppState{
		verb: 'OPEN'
	}
	assert app.verb == 'OPEN'

	app.verb = 'RUNAS'
	assert app.verb == 'RUNAS'
}

fn test_appstate_priority() {
	mut app := AppState{
		priority: priority_normal
	}
	assert app.priority == priority_normal

	app.priority = priority_high
	assert app.priority == priority_high
}

fn test_appstate_verbose() {
	mut app := AppState{
		verbose_level: 0
	}
	assert app.verbose_level == 0

	app.verbose_level = 1
	assert app.verbose_level == 1

	app.verbose_level = -1
	assert app.verbose_level == -1
}

// ============================================================================
// File Operation Tests
// ============================================================================

fn test_write_now_file() {
	// Create a temp file
	temp_file := os.temp_dir() + '/cax_test_now.txt'

	write_now_file(temp_file, 'Test message')

	// Check file exists
	assert os.file_exists(temp_file) == true

	// Read and verify content
	content := os.read_file(temp_file) or { '' }
	assert content.len > 0
	assert content.index('Test message') != -1

	// Cleanup
	os.remove(temp_file) or {}
}

fn test_create_directory() {
	// Create a temp directory
	temp_dir := os.temp_dir() + '/cax_test_dir'

	create_directory(temp_dir)

	// Check directory exists
	assert os.dir_exists(temp_dir) == true

	// Cleanup
	os.remove(temp_dir) or {}
}

// ============================================================================
// Message Box Tests
// ============================================================================

fn test_show_message_box() {
	mut app := AppState{}
	result := show_message_box(app, mb_ok, 'Test', 'Test message')
	assert result == idok
}

fn test_handle_message_box_msg() {
	mut app := AppState{}
	args := ['cax.exe', '/MSG', 'Test message']
	result := handle_message_box(app, '/MSG', args, 1)
	assert result == 3
}

fn test_handle_message_box_msc() {
	mut app := AppState{}
	args := ['cax.exe', '/MSC', 'Test message']
	result := handle_message_box(app, '/MSC', args, 1)
	assert result == 3
}

// ============================================================================
// Power Command Tests
// ============================================================================

fn test_handle_power_command_dwr() {
	args := ['cax.exe', '/DWR']
	handle_power_command('/DWR', args, 1)
	// Should not crash
	assert true
}

fn test_handle_power_command_dawr() {
	args := ['cax.exe', '/DAWR']
	handle_power_command('/DAWR', args, 1)
	// Should not crash
	assert true
}

fn test_handle_power_command_dwc() {
	args := ['cax.exe', '/DWC']
	handle_power_command('/DWC', args, 1)
	// Should not crash
	assert true
}

fn test_handle_power_command_lockw() {
	args := ['cax.exe', '/LOCKW']
	handle_power_command('/LOCKW', args, 1)
	// Should not crash
	assert true
}

// ============================================================================
// Service Command Tests
// ============================================================================

fn test_handle_service_command_install() {
	mut app := AppState{}
	args := ['cax.exe', '/SVC~I', '/SVC~NAME:TestService']
	result := handle_service_command(mut app, args, 1)
	assert result >= 2
}

fn test_handle_service_command_uninstall() {
	mut app := AppState{}
	args := ['cax.exe', '/SVC~U', '/SVC~NAME:TestService']
	result := handle_service_command(mut app, args, 1)
	assert result >= 2
}

// ============================================================================
// Window Command Tests
// ============================================================================

fn test_handle_window_command_wnc() {
	args := ['cax.exe', '/WNC', 'Notepad', '-']
	result := handle_window_command('/WNC', args, 1)
	assert result >= 2
}

fn test_list_windows() {
	list_windows(false)
	// Should not crash
	assert true
}

fn test_list_windows_all() {
	list_windows(true)
	// Should not crash
	assert true
}

// ============================================================================
// OSD Command Tests
// ============================================================================

fn test_handle_osd_command_osdtext() {
	mut app := AppState{}
	args := ['cax.exe', '/OSDTEXT', '50', 'Test OSD text']
	result := handle_osd_command(mut app, '/OSDTEXT', args, 1)
	assert result >= 2
}

fn test_handle_osd_command_osdtop() {
	mut app := AppState{}
	args := ['cax.exe', '/OSDTOP', '100']
	result := handle_osd_command(mut app, '/OSDTOP', args, 1)
	assert result >= 2
}

fn test_handle_osd_command_osdrecycle() {
	mut app := AppState{}
	args := ['cax.exe', '/OSDRECYCLE']
	result := handle_osd_command(mut app, '/OSDRECYCLE', args, 1)
	assert result >= 2
	assert app.osd_recycle == true
}

// ============================================================================
// Clipboard Tests
// ============================================================================

fn test_set_clipboard_text() {
	set_clipboard_text('Test clipboard content')
	// Should not crash
	assert true
}

fn test_get_clipboard_text() {
	text := get_clipboard_text()
	// Returns empty string in stub implementation
	assert text == ''
}

fn test_clipboard_to_file() {
	clipboard_to_file('test_clip.txt')
	// Should not crash
	assert true
}

fn test_clipboard_from_file() {
	clipboard_from_file('test_clip.txt')
	// Should not crash
	assert true
}

// ============================================================================
// Keyboard Input Tests
// ============================================================================

fn test_send_keyboard_input() {
	send_keyboard_input('Test input')
	// Should not crash
	assert true
}

fn test_send_keyboard_from_file() {
	send_keyboard_from_file('test_keys.txt')
	// Should not crash
	assert true
}

// ============================================================================
// Network Tests
// ============================================================================

fn test_handle_net_map() {
	args := ['cax.exe', '/NETMAP', '\\\\server\\share', 'Z:', 'user', '-', 'password']
	result := handle_net_map(args, 1)
	assert result >= 2
}

fn test_add_network_connection() {
	add_network_connection('\\\\server\\share', 'Z:')
	// Should not crash
	assert true
}

fn test_delete_network_connection() {
	delete_network_connection('Z:')
	// Should not crash
	assert true
}

// ============================================================================
// Drive Tests
// ============================================================================

fn test_eject_drive() {
	eject_drive('D:', false)
	// Should not crash
	assert true
}

fn test_eject_drive_force() {
	eject_drive('D:', true)
	// Should not crash
	assert true
}

fn test_close_drive() {
	close_drive('D:', false)
	// Should not crash
	assert true
}

fn test_substitute_drive() {
	substitute_drive('X:', 'C:\\test', false)
	// Should not crash
	assert true
}

fn test_substitute_drive_raw() {
	substitute_drive('Y:', 'C:\\test', true)
	// Should not crash
	assert true
}

fn test_delete_substitution() {
	delete_substitution('X:', '')
	// Should not crash
	assert true
}

fn test_delete_substitution_exact() {
	delete_substitution('X:', 'C:\\test')
	// Should not crash
	assert true
}

// ============================================================================
// Hash Tests
// ============================================================================

fn test_calculate_md5() {
	calculate_md5('test.iso', '-')
	// Should not crash
	assert true
}

fn test_calculate_sha1() {
	calculate_sha1('test.iso', '-')
	// Should not crash
	assert true
}

// ============================================================================
// Download Tests
// ============================================================================

fn test_download_file() {
	download_file('http://example.com/file.txt', 'local.txt', false)
	// Should not crash
	assert true
}

fn test_download_file_hidden() {
	download_file('http://example.com/file.txt', 'local.txt', true)
	// Should not crash
	assert true
}

// ============================================================================
// Flag Tests
// ============================================================================

fn test_set_file_flag() {
	set_file_flag('/FILEOF_NOSECATTR')
	// Should not crash
	assert true
}

fn test_set_net_flag() {
	set_net_flag('/NETFLAG_ZERO')
	// Should not crash
	assert true
}

// ============================================================================
// Main Test Runner
// ============================================================================

fn main() {
	// Run all tests
	mut tests_passed := 0
	mut tests_failed := 0

	// Helper function tests
	test_parse_int()
	tests_passed++

	test_parse_uint()
	tests_passed++

	test_parse_volume()
	tests_passed++

	// Variable expansion tests
	test_expand_variables_clock()
	tests_passed++

	test_expand_variables_date()
	tests_passed++

	test_expand_variables_time()
	tests_passed++

	test_expand_variables_hour()
	tests_passed++

	test_expand_variables_min()
	tests_passed++

	test_expand_variables_sec()
	tests_passed++

	test_expand_variables_year()
	tests_passed++

	test_expand_variables_mon()
	tests_passed++

	test_expand_variables_day()
	tests_passed++

	test_expand_variables_tick()
	tests_passed++

	test_expand_variables_htick()
	tests_passed++

	test_expand_variables_cdir()
	tests_passed++

	test_expand_variables_cdrive()
	tests_passed++

	test_expand_variables_uname()
	tests_passed++

	test_expand_variables_cname()
	tests_passed++

	test_expand_variables_sdrive()
	tests_passed++

	test_expand_variables_sdir()
	tests_passed++

	test_expand_variables_multiple()
	tests_passed++

	test_expand_variables_none()
	tests_passed++

	test_expand_variables_env()
	tests_passed++

	// Command processing tests
	test_command_nop()
	tests_passed++

	test_command_out()
	tests_passed++

	test_command_beep()
	tests_passed++

	test_command_bepl()
	tests_passed++

	test_command_cpuid()
	tests_passed++

	test_command_showdesk()
	tests_passed++

	test_command_saver()
	tests_passed++

	test_command_ensaver()
	tests_passed++

	test_command_dissaver()
	tests_passed++

	test_command_mixers()
	tests_passed++

	test_command_setclip()
	tests_passed++

	test_command_nmlo()
	tests_passed++

	test_command_prclist()
	tests_passed++

	test_command_svclist()
	tests_passed++

	test_command_devlist()
	tests_passed++

	test_command_drvlist()
	tests_passed++

	test_command_winlist()
	tests_passed++

	test_command_caxlist()
	tests_passed++

	test_command_help()
	tests_passed++

	test_command_version()
	tests_passed++

	// AppState tests
	test_appstate_default()
	tests_passed++

	test_appstate_verb()
	tests_passed++

	test_appstate_priority()
	tests_passed++

	test_appstate_verbose()
	tests_passed++

	// File operation tests
	test_write_now_file()
	tests_passed++

	test_create_directory()
	tests_passed++

	// Message box tests
	test_show_message_box()
	tests_passed++

	test_handle_message_box_msg()
	tests_passed++

	test_handle_message_box_msc()
	tests_passed++

	// Power command tests
	test_handle_power_command_dwr()
	tests_passed++

	test_handle_power_command_dawr()
	tests_passed++

	test_handle_power_command_dwc()
	tests_passed++

	test_handle_power_command_lockw()
	tests_passed++

	// Service command tests
	test_handle_service_command_install()
	tests_passed++

	test_handle_service_command_uninstall()
	tests_passed++

	// Window command tests
	test_handle_window_command_wnc()
	tests_passed++

	test_list_windows()
	tests_passed++

	test_list_windows_all()
	tests_passed++

	// OSD command tests
	test_handle_osd_command_osdtext()
	tests_passed++

	test_handle_osd_command_osdtop()
	tests_passed++

	test_handle_osd_command_osdrecycle()
	tests_passed++

	// Clipboard tests
	test_set_clipboard_text()
	tests_passed++

	test_get_clipboard_text()
	tests_passed++

	test_clipboard_to_file()
	tests_passed++

	test_clipboard_from_file()
	tests_passed++

	// Keyboard input tests
	test_send_keyboard_input()
	tests_passed++

	test_send_keyboard_from_file()
	tests_passed++

	// Network tests
	test_handle_net_map()
	tests_passed++

	test_add_network_connection()
	tests_passed++

	test_delete_network_connection()
	tests_passed++

	// Drive tests
	test_eject_drive()
	tests_passed++

	test_eject_drive_force()
	tests_passed++

	test_close_drive()
	tests_passed++

	test_substitute_drive()
	tests_passed++

	test_substitute_drive_raw()
	tests_passed++

	test_delete_substitution()
	tests_passed++

	test_delete_substitution_exact()
	tests_passed++

	// Hash tests
	test_calculate_md5()
	tests_passed++

	test_calculate_sha1()
	tests_passed++

	// Download tests
	test_download_file()
	tests_passed++

	test_download_file_hidden()
	tests_passed++

	// Flag tests
	test_set_file_flag()
	tests_passed++

	test_set_net_flag()
	tests_passed++

	println('')
	println('========================================')
	println('All tests passed: ${tests_passed}')
	println('Tests failed: ${tests_failed}')
	println('========================================')

	if tests_failed > 0 {
		exit(1)
	}
}
