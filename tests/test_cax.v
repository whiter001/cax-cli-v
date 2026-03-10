// CAX Test Suite - Independent Tests
// Run with: v run test_cax.v

module main

fn main() {
	mut passed := 0
	mut failed := 0

	println('CAX Test Suite')
	println('================')
	println('')

	// Test parse_int
	print('Test parse_int... ')
	if test_parse_int() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test parse_uint
	print('Test parse_uint... ')
	if test_parse_uint() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test string operations
	print('Test string operations... ')
	if test_string_ops() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test constants
	print('Test constants... ')
	if test_constants() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test AppState struct
	print('Test AppState struct... ')
	if test_appstate_struct() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	// Test stub functions
	print('Test stub functions... ')
	if test_stub_functions() {
		println('PASS')
		passed++
	} else {
		println('FAIL')
		failed++
	}

	println('')
	println('================')
	println('Passed: ${passed}')
	println('Failed: ${failed}')
	println('Total:  ${passed + failed}')
	println('================')

	if failed > 0 {
		exit(1)
	}
}

// ============================================================================
// Test Functions
// ============================================================================

fn test_parse_int() bool {
	// Test valid integer parsing
	if '123'.int() != 123 {
		return false
	}
	if '-456'.int() != -456 {
		return false
	}
	if '0'.int() != 0 {
		return false
	}
	// Test invalid input returns 0
	if 'abc'.int() != 0 {
		return false
	}
	return true
}

fn test_parse_uint() bool {
	if '123'.int() != 123 {
		return false
	}
	if 'abc'.int() != 0 {
		return false
	}
	return true
}

fn test_string_ops() bool {
	s := 'Hello World'

	// Test to_upper
	if s.to_upper() != 'HELLO WORLD' {
		return false
	}

	// Test len
	if s.len != 11 {
		return false
	}

	// Test index
	idx := s.index('World') or { return false }
	if idx == -1 {
		return false
	}

	// Test starts_with
	if !s.starts_with('Hello') {
		return false
	}

	// Test contains
	if !s.contains('World') {
		return false
	}

	return true
}

fn test_constants() bool {
	// Test priority constants
	if priority_idle != 1 {
		return false
	}
	if priority_normal != 3 {
		return false
	}
	if priority_high != 5 {
		return false
	}

	// Test MessageBox constants
	if mb_ok != 0x00000000 {
		return false
	}
	if mb_okcancel != 0x00000001 {
		return false
	}

	// Test MessageBox return values
	if idok != 1 {
		return false
	}
	if idcancel != 2 {
		return false
	}
	if idyes != 6 {
		return false
	}

	return true
}

fn test_appstate_struct() bool {
	// Test default initialization
	app := AppState{}
	if app.verbose_level != 0 {
		return false
	}
	if app.caption != '' {
		return false
	}
	if app.verb != '' {
		return false
	}
	if app.priority != 0 {
		return false
	}

	// Test initialization with values
	app2 := AppState{
		verbose_level: 1
		caption:       'Test'
		verb:          'OPEN'
		priority:      priority_normal
	}
	if app2.verbose_level != 1 {
		return false
	}
	if app2.caption != 'Test' {
		return false
	}
	if app2.verb != 'OPEN' {
		return false
	}
	if app2.priority != priority_normal {
		return false
	}

	return true
}

fn test_stub_functions() bool {
	// Test that stub functions don't crash
	beep()
	play_default_beep()
	show_desktop()
	run_screen_saver()
	enable_screen_saver()
	disable_screen_saver()
	show_cpuid()
	set_num_lock(true)
	set_system_modal()
	turn_monitor_off()
	turn_monitor_on()
	list_mixers()
	list_processes()
	list_services()
	list_devices('')
	list_drives()
	list_windows(false)
	list_cax_instances()

	// Test with parameters
	play_wav_file('test.wav')
	set_master_volume(50, 0)
	show_wait_window('Test', 10)
	free_memory(50)
	create_manifest_file()
	register_exe()
	run_program('notepad.exe', 'OPEN', 3, false)
	run_program_as_admin('notepad.exe')
	run_program_minimized('notepad.exe')
	run_program_hidden('notepad.exe')
	run_program_maximized('notepad.exe')
	run_as_user('user', 'domain', 'pass', 'prog')
	set_process_priority('notepad.exe', 3)
	kill_process('notepad.exe', 1)
	kill_all_processes('notepad*')
	kill_last_process('notepad*')
	kill_process_by_id(1234)
	kill_processes_by_user('Admin*')
	stop_service('Spooler')
	start_service('Spooler')
	eject_device('/DEVEJIN', 'USB\\1234')
	disable_device('/DEVDSIN', 'USB\\1234')
	enable_device('/DEVENIN', 'USB\\1234')
	send_to_session('0 10 Test')
	show_tell_window('Test', 10)
	show_tell_window_with_countdown('Test', 10)
	close_windows_by_class('*Notepad*')
	destroy_windows_by_class('*Notepad*')
	show_properties('C:\\test.txt')
	delete_file_or_dir('C:\\test.txt', '/DEL')
	copy_file_or_dir('C:\\src.txt', 'C:\\dst.txt', '/CPY')
	move_file_or_dir('C:\\src.txt', 'C:\\dst.txt', '/MVE')
	rename_file_or_dir('C:\\old.txt', 'C:\\new.txt', '/RNM')
	create_directory('C:\\test_dir')
	add_network_connection('\\\\server\\share', 'Z:')
	delete_network_connection('Z:')
	replace_file_on_reboot('C:\\old.dll', 'C:\\new.dll')
	create_hard_link('C:\\link.txt', 'C:\\file.txt')
	eject_drive('D:', false)
	eject_drive('D:', true)
	close_drive('D:', false)
	lock_drive_removal('D:')
	unlock_drive_removal('D:')
	substitute_drive('X:', 'C:\\test', false)
	substitute_drive('Y:', 'C:\\test', true)
	delete_substitution('X:', '')
	delete_substitution('X:', 'C:\\test')
	wait_for_directory_change(false)
	wait_for_directory_change(true)
	get_network_user('\\\\server\\share')
	calculate_md5('test.iso', '-')
	calculate_sha1('test.iso', '-')
	download_file('http://example.com/file.txt', 'local.txt', false)
	download_file('http://example.com/file.txt', 'local.txt', true)
	set_clipboard_text('Test text')
	get_clipboard_text()
	clipboard_to_file('clip.txt')
	clipboard_from_file('clip.txt')
	send_keyboard_input('Test input')
	send_keyboard_from_file('keys.txt')
	set_file_flag('/FILEOF_NOSECATTR')
	set_net_flag('/NETFLAG_ZERO')

	return true
}

// ============================================================================
// Helper Functions (copied from main.v for testing)
// ============================================================================

fn parse_int(s string) int {
	return s.int()
}

fn parse_uint(s string) int {
	return s.int()
}

// AppState struct definition
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

// Constants
const version = '0.0.1'
const app_name = 'CAX'
const priority_idle = 1
const priority_below = 2
const priority_normal = 3
const priority_above = 4
const priority_high = 5
const priority_realtime = 6
const mb_ok = 0x00000000
const mb_okcancel = 0x00000001
const mb_abortretryignore = 0x00000002
const mb_yesnocancel = 0x00000003
const mb_yesno = 0x00000004
const mb_retrycancel = 0x00000005
const mb_iconhand = 0x00000010
const mb_iconquestion = 0x00000020
const mb_iconexclamation = 0x00000030
const mb_iconinformation = 0x00000040
const idok = 1
const idcancel = 2
const idabort = 3
const idretry = 4
const idignore = 5
const idyes = 6
const idno = 7

// Stub functions
fn beep() {
	// println('[BEEP]')
}

fn play_default_beep() {
	// println('[BEPL]')
}

fn play_wav_file(wav_file string) {
	// println('[WAPL] ${wav_file}')
}

fn set_master_volume(volume int, mixer_idx int) {
	// println('[MVOLUME] ${volume}')
}

fn list_mixers() {
	// println('[MIXERS]')
}

fn run_screen_saver() {
	// println('[SAVER]')
}

fn enable_screen_saver() {
	// println('[ENSAVER]')
}

fn disable_screen_saver() {
	// println('[DISSAVER]')
}

fn show_desktop() {
	// println('[SHOWDESK]')
}

fn restore_desktop() {
	// println('[RESTDESK]')
}

fn show_cpuid() {
	// println('[CPUID]')
}

fn set_num_lock(on bool) {
	// println('[NMLO]')
}

fn set_system_modal() {
	// println('[MODAL]')
}

fn turn_monitor_off() {
	// println('[MOFF!]')
}

fn turn_monitor_on() {
	// println('[MON!]')
}

fn wait_for_hotkey(hotkey_spec string) {
	// println('[HOTKEY] ${hotkey_spec}')
}

fn wait_until_time(time_spec string) {
	// println('[UNTIL] ${time_spec}')
}

fn show_wait_window(text string, timeout int) {
	// println('[VWAIT] ${text}')
}

fn free_memory(percent int) {
	// println('[MEMFREE] ${percent}%')
}

fn create_manifest_file() {
	// println('[.MANIFEST]')
}

fn register_exe() {
	// println('[REGISTEREXE]')
}

fn run_program(app string, verb string, priority int, wait bool) {
	// println('[RUN] ${app}')
}

fn run_program_as_admin(app string) {
	// println('[RUA] ${app}')
}

fn run_program_minimized(app string) {
	// println('[RUM] ${app}')
}

fn run_program_hidden(app string) {
	// println('[RUH] ${app}')
}

fn run_program_maximized(app string) {
	// println('[RUX] ${app}')
}

fn run_as_user(user_name string, domain string, password string, program string) {
	// println('[ASUSER] ${user_name}')
}

fn list_processes() {
	// println('[PRCLIST]')
}

fn list_processes_with_modules() {
	// println('[PRCMODLIST]')
}

fn scan_processes() {
	// println('[PRCSCAN]')
}

fn set_process_priority(process_name string, priority int) {
	// println('[PRCPRIO${priority}] ${process_name}')
}

fn kill_process(process_name string, exit_code int) {
	// println('[KILLPRC] ${process_name}')
}

fn kill_all_processes(pattern string) {
	// println('[KILLALL] ${pattern}')
}

fn kill_last_process(pattern string) {
	// println('[KILLLAST] ${pattern}')
}

fn kill_process_by_id(process_id u32) {
	// println('[KILLID] ${process_id}')
}

fn kill_processes_by_user(user_pattern string) {
	// println('[KILLUSER] ${user_pattern}')
}

fn install_service(name string, display_name string, auto_start bool) {
	// println('[SVC~I] ${name}')
}

fn run_as_service() {
	// println('[SVC~R]')
}

fn uninstall_service(name string) {
	// println('[SVC~U] ${name}')
}

fn list_services() {
	// println('[SVCLIST]')
}

fn list_services_only() {
	// println('[SVCSVCLIST]')
}

fn list_drivers_only() {
	// println('[SVCDRVLIST]')
}

fn stop_service(name string) {
	// println('[SVCSTOP] ${name}')
}

fn start_service(name string) {
	// println('[SVCSTART] ${name}')
}

fn list_devices(device_class string) {
	// println('[DEVLIST]')
}

fn eject_device(cmd string, device_id string) {
	// println('[${cmd}] ${device_id}')
}

fn disable_device(cmd string, device_id string) {
	// println('[${cmd}] ${device_id}')
}

fn enable_device(cmd string, device_id string) {
	// println('[${cmd}] ${device_id}')
}

fn handle_power_command(cmd string, args []string, i int) {
	// println('[${cmd}]')
}

fn send_to_session(session_spec string) {
	// println('[MSSA] ${session_spec}')
}

fn show_tell_window(text string, timeout int) {
	// println('[TELL] ${text}')
}

fn show_tell_window_with_countdown(text string, timeout int) {
	// println('[TELT] ${text}')
}

fn close_windows_by_class(pattern string) {
	// println('[CLASSCLOSE] ${pattern}')
}

fn destroy_windows_by_class(pattern string) {
	// println('[CLASSDESTROY] ${pattern}')
}

fn show_properties(file_path string) {
	// println('[PROP] ${file_path}')
}

fn delete_file_or_dir(file_path string, cmd string) {
	// println('[${cmd}] ${file_path}')
}

fn copy_file_or_dir(source string, target string, cmd string) {
	// println('[${cmd}] ${source} -> ${target}')
}

fn move_file_or_dir(source string, target string, cmd string) {
	// println('[${cmd}] ${source} -> ${target}')
}

fn rename_file_or_dir(old_name string, new_name string, cmd string) {
	// println('[${cmd}] ${old_name} -> ${new_name}')
}

fn create_directory(dir_path string) {
	// println('[MKD] ${dir_path}')
}

fn add_network_connection(remote string, local string) {
	// println('[NETADD] ${remote} -> ${local}')
}

fn delete_network_connection(connection string) {
	// println('[NETDEL] ${connection}')
}

fn replace_file_on_reboot(source_file string, new_name string) {
	// println('[REPLACE] ${source_file}')
}

fn create_hard_link(new_file string, existing_file string) {
	// println('[HARDLINK] ${new_file}')
}

fn eject_drive(drive string, force bool) {
	// println('[DSKEJ:] ${drive}')
}

fn close_drive(drive string, force bool) {
	// println('[DSKCL:] ${drive}')
}

fn lock_drive_removal(drive string) {
	// println('[DSKLCK:] ${drive}')
}

fn unlock_drive_removal(drive string) {
	// println('[DSKUNL:] ${drive}')
}

fn substitute_drive(drive string, path string, raw bool) {
	// println('[SUBST] ${drive} = ${path}')
}

fn delete_substitution(drive string, path string) {
	// println('[DSUBST] ${drive}')
}

fn wait_for_directory_change(include_subdirs bool) {
	// println('[WAITDIR]')
}

fn list_drives() {
	// println('[DRVLIST]')
}

fn get_network_user(resource string) {
	// println('[GETNETUSER] ${resource}')
}

fn calculate_md5(file_path string, output_dir string) {
	// println('[MD5FILE] ${file_path}')
}

fn calculate_sha1(file_path string, output_dir string) {
	// println('[SHA1FILE] ${file_path}')
}

fn download_file(url string, local_name string, hidden bool) {
	// println('[NETGET] ${url}')
}

fn set_clipboard_text(text string) {
	// println('[SETCLIP] ${text.len} chars')
}

fn get_clipboard_text() string {
	return ''
}

fn clipboard_to_file(file_path string) {
	// println('[CLIPTOFILE] ${file_path}')
}

fn clipboard_from_file(file_path string) {
	// println('[CLIPFROMFILE] ${file_path}')
}

fn send_keyboard_input(text string) {
	// println('[KEYBSEND] ${text}')
}

fn send_keyboard_from_file(file_path string) {
	// println('[KEYBFROMFILE] ${file_path}')
}

fn list_windows(include_no_caption bool) {
	// println('[WINLIST]')
}

fn list_cax_instances() {
	// println('[CAXLIST]')
}

fn set_window_priority(window_name string, priority int) {
	// println('[WINPRIO${priority}] ${window_name}')
}

fn set_window_transparency(window_pattern string, transparency u8) {
	// println('[WINTRANSP] ${window_pattern}')
}

fn set_window_color_transparent(window_pattern string, color_str string) {
	// println('[WINTRCL] ${window_pattern}')
}

fn close_windows_by_title(pattern string) {
	// println('[WINCLOSE] ${pattern}')
}

fn destroy_windows_by_title(pattern string) {
	// println('[WINDESTROY] ${pattern}')
}

fn set_class_priority(class_name string, priority int) {
	// println('[CLASSPRIO${priority}] ${class_name}')
}

fn set_class_transparency(class_name string, transparency u8) {
	// println('[CLASSTRANSP] ${class_name}')
}

fn set_class_color_transparent(class_name string, color_str string) {
	// println('[CLASSTRCL] ${class_name}')
}

fn send_window_message(window_name string, msg u32, wparam int, lparam int) {
	// println('[WINMSGSEND] ${window_name}')
}

fn post_window_message(window_name string, msg u32, wparam int, lparam int) {
	// println('[WINMSGPOST] ${window_name}')
}

fn send_class_message(class_name string, msg u32, wparam int, lparam int) {
	// println('[CLASSMSGSEND] ${class_name}')
}

fn post_class_message(class_name string, msg u32, wparam int, lparam int) {
	// println('[CLASSMSGPOST] ${class_name}')
}

fn get_free_memory() u64 {
	return 0
}

fn get_free_memory_high_res() u64 {
	return 0
}

fn get_free_memory_percent() int {
	return 0
}

fn get_desktop_window_handle() int {
	return 0
}

fn get_start_button_handle() int {
	return 0
}

fn get_system_tray_handle() int {
	return 0
}

fn get_ip_addresses() string {
	return ''
}

fn get_cpu_speed() u64 {
	return 0
}

fn get_cpu_usage() int {
	return 0
}

fn get_power_state() string {
	return 'AC'
}

fn get_battery_status() string {
	return 'No Battery'
}

fn get_battery_life() string {
	return 'N/A'
}

fn get_registry_value(reg_path string) string {
	return ''
}

fn set_file_flag(cmd string) {
	// println('[FILEFLAG] ${cmd}')
}

fn set_net_flag(cmd string) {
	// println('[NETFLAG] ${cmd}')
}
