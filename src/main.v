module main

import os
import time

// ============================================================================
// Constants
// ============================================================================

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

// ============================================================================
// Global State
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

// ============================================================================
// Main Entry Point
// ============================================================================

fn main() {
	mut app := AppState{
		verbose_level: 0
		caption:       ''
		osd_position:  20
		verb:          'OPEN'
		priority:      priority_normal
	}

	args := os.args
	if args.len < 2 {
		show_help()
		return
	}

	mut i := 1
	for i < args.len {
		cmd := args[i].to_upper()

		if cmd.starts_with('/') {
			app, i = process_command(app, args, i)
		} else {
			i++
		}
	}
}

// ============================================================================
// Command Processing
// ============================================================================

fn process_command(app AppState, args []string, idx int) (AppState, int) {
	mut i := idx
	mut mut_app := app
	cmd := args[i].to_upper()

	match cmd {
		'/???', '/ASK' {
			if i + 1 < args.len {
				i++
				text := expand_variables(args[i])
				result := show_message_box(mut_app, mb_okcancel | mb_iconquestion, 'Ask',
					text)
				if result != idok {
					exit(result)
				}
			}
			i++
		}
		'/BEEP' {
			beep()
			i++
		}
		'/BEPL' {
			play_default_beep()
			i++
		}
		'/WAPL' {
			if i + 1 < args.len {
				i++
				wav_file := expand_variables(args[i])
				play_wav_file(wav_file)
			}
			i++
		}
		'/MVOLUME', '/MVOLUME1', '/MVOLUME2', '/MVOLUME3', '/MVOLUME4' {
			if i + 1 < args.len {
				i++
				vol_str := args[i]
				volume := parse_int(vol_str)
				mut mixer_idx := 0
				if cmd.len > 8 {
					mixer_idx = int(cmd[8] - `0`)
				}
				set_master_volume(volume, mixer_idx)
			}
			i++
		}
		'/MIXERS' {
			list_mixers()
			i++
		}
		'/SAVER' {
			run_screen_saver()
			i++
		}
		'/ENSAVER' {
			enable_screen_saver()
			i++
		}
		'/DISSAVER' {
			disable_screen_saver()
			i++
		}
		'/SHOWDESK' {
			show_desktop()
			i++
		}
		'/RESTDESK' {
			restore_desktop()
			i++
		}
		'/CPUID' {
			show_cpuid()
			i++
		}
		'/NOP' {
			i++
		}
		'/OUT' {
			if i + 1 < args.len {
				i++
				text := expand_variables(args[i])
				println(text)
			}
			i++
		}
		'/SETCLIP' {
			if i + 1 < args.len {
				i++
				text := expand_variables(args[i])
				set_clipboard_text(text)
			}
			i++
		}
		'/CLIPTOFILE' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				clipboard_to_file(file_path)
			}
			i++
		}
		'/CLIPFROMFILE' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				clipboard_from_file(file_path)
			}
			i++
		}
		'/KEYBSEND' {
			if i + 1 < args.len {
				i++
				text := expand_variables(args[i])
				send_keyboard_input(text)
			}
			i++
		}
		'/KEYBFROMFILE' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				send_keyboard_from_file(file_path)
			}
			i++
		}
		'/NMLO' {
			set_num_lock(true)
			i++
		}
		'/MODAL' {
			set_system_modal()
			i++
		}
		'/NOW' {
			if i + 2 < args.len {
				i++
				file_path := expand_variables(args[i])
				i++
				text := expand_variables(args[i])
				write_now_file(file_path, text)
			} else if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				write_now_file(file_path, '')
			}
			i++
		}
		'/MOFF!' {
			turn_monitor_off()
			i++
		}
		'/MON!' {
			turn_monitor_on()
			i++
		}
		'/HOTKEY' {
			if i + 1 < args.len {
				i++
				hotkey_spec := args[i]
				wait_for_hotkey(hotkey_spec)
			}
			i++
		}
		'/UNTIL' {
			if i + 1 < args.len {
				i++
				time_spec := args[i]
				wait_until_time(time_spec)
			}
			i++
		}
		'/VWAIT' {
			if i + 1 < args.len {
				i++
				timeout_str := args[i]
				timeout := parse_int(timeout_str)
				if i + 1 < args.len {
					i++
					text := expand_variables(args[i])
					show_wait_window(text, timeout)
				}
			}
			i++
		}
		'/WAIT' {
			if i + 1 < args.len {
				i++
				timeout_str := args[i]
				timeout := parse_int(timeout_str)
				time.sleep(time.Duration(timeout * 100) * time.millisecond)
			}
			i++
		}
		'/CYCLE' {
			if i + 1 < args.len {
				i++
				timeout_str := args[i]
				mut_app.cycle_timeout = parse_int(timeout_str)
				mut_app.cycle_count = 1
			}
			i++
		}
		'/REPEAT' {
			if i + 1 < args.len {
				i++
				repeat_str := args[i]
				mut_app.repeat_count = parse_int(repeat_str)
				mut_app.repeat_start = i + 1
			}
			i++
		}
		'/XTIMES' {
			if i + 1 < args.len {
				i++
				xtimes_str := args[i]
				mut_app.xtimes = parse_int(xtimes_str)
			}
			i++
		}
		'/MEMFREE' {
			if i + 1 < args.len {
				i++
				percent_str := args[i]
				percent := parse_int(percent_str)
				free_memory(percent)
			}
			i++
		}
		'/.MANIFEST' {
			create_manifest_file()
			i++
		}
		'/REGISTEREXE' {
			register_exe()
			i++
		}
		'/RUN' {
			if i + 1 < args.len {
				i++
				app_to_run := expand_variables(args[i])
				run_program(app_to_run, mut_app.verb, mut_app.priority, false)
			}
			i++
		}
		'/RUA' {
			if i + 1 < args.len {
				i++
				app_to_run := expand_variables(args[i])
				run_program_as_admin(app_to_run)
			}
			i++
		}
		'/RUM' {
			if i + 1 < args.len {
				i++
				app_to_run := expand_variables(args[i])
				run_program_minimized(app_to_run)
			}
			i++
		}
		'/RUH' {
			if i + 1 < args.len {
				i++
				app_to_run := expand_variables(args[i])
				run_program_hidden(app_to_run)
			}
			i++
		}
		'/RUX' {
			if i + 1 < args.len {
				i++
				app_to_run := expand_variables(args[i])
				run_program_maximized(app_to_run)
			}
			i++
		}
		'/VERB:' {
			if i + 1 < args.len {
				i++
				mut_app.verb = args[i]
			}
			i++
		}
		'/PRIO:' {
			if i + 1 < args.len {
				i++
				prio_str := args[i]
				mut_app.priority = parse_int(prio_str)
			}
			i++
		}
		'/ASUSER' {
			if i + 4 < args.len {
				i++
				user_name := args[i]
				i++
				domain := args[i]
				i++
				password := args[i]
				i++
				program := expand_variables(args[i])
				run_as_user(user_name, domain, password, program)
			}
			i++
		}
		'/PRCLIST' {
			list_processes()
			i++
		}
		'/PRCMODLIST' {
			list_processes_with_modules()
			i++
		}
		'/PRCSCAN' {
			scan_processes()
			i++
		}
		'/PRCPRIO1', '/PRCPRIO2', '/PRCPRIO3', '/PRCPRIO4', '/PRCPRIO5', '/PRCPRIO6' {
			if i + 1 < args.len {
				i++
				process_name := args[i]
				priority := int(cmd[7] - `0`)
				set_process_priority(process_name, priority)
			}
			i++
		}
		'/KILLPRC' {
			if i + 1 < args.len {
				i++
				process_name := expand_variables(args[i])
				kill_process(process_name, 1)
			}
			i++
		}
		'/KILLALL' {
			if i + 1 < args.len {
				i++
				pattern := expand_variables(args[i])
				kill_all_processes(pattern)
			}
			i++
		}
		'/KILLLAST' {
			if i + 1 < args.len {
				i++
				pattern := expand_variables(args[i])
				kill_last_process(pattern)
			}
			i++
		}
		'/KILLID' {
			if i + 1 < args.len {
				i++
				id_str := args[i]
				process_id := parse_uint(id_str)
				kill_process_by_id(u32(process_id))
			}
			i++
		}
		'/KILLUSER' {
			if i + 1 < args.len {
				i++
				user_pattern := args[i]
				kill_processes_by_user(user_pattern)
			}
			i++
		}
		'/KILLCODE:' {
			if i + 1 < args.len {
				i++
				exit_code_str := args[i]
				mut exit_code := parse_int(exit_code_str)
				if exit_code == 0 {
					exit_code = 1
				}
				if i + 1 < args.len {
					i++
					process_name := args[i]
					kill_process(process_name, exit_code)
				}
			}
			i++
		}
		'/SVC~I', '/SVC~IA', '/SVC~R', '/SVC~U' {
			mut_app, i = handle_service_command(mut_app, args, i)
		}
		'/SVCLIST' {
			list_services()
			i++
		}
		'/SVCSVCLIST' {
			list_services_only()
			i++
		}
		'/SVCDRVLIST' {
			list_drivers_only()
			i++
		}
		'/SVCSTOP' {
			if i + 1 < args.len {
				i++
				service_name := args[i]
				stop_service(service_name)
			}
			i++
		}
		'/SVCSTART' {
			if i + 1 < args.len {
				i++
				service_name := args[i]
				start_service(service_name)
			}
			i++
		}
		'/DEVLIST' {
			list_devices('')
			i++
		}
		'/DEVLICL' {
			if i + 1 < args.len {
				i++
				device_class := args[i]
				list_devices(device_class)
			}
			i++
		}
		'/DEVEJIN', '/DEVEJDN', '/DEVEJDI', '/DEVEJDP' {
			if i + 1 < args.len {
				i++
				device_id := args[i]
				eject_device(cmd, device_id)
			}
			i++
		}
		'/DEVDSIN', '/DEVDSDN', '/DEVDSDI', '/DEVDSDP' {
			if i + 1 < args.len {
				i++
				device_id := args[i]
				disable_device(cmd, device_id)
			}
			i++
		}
		'/DEVENIN', '/DEVENDN', '/DEVENDI', '/DEVENDP' {
			if i + 1 < args.len {
				i++
				device_id := args[i]
				enable_device(cmd, device_id)
			}
			i++
		}
		'/DARD:', '/DRD:', '/DARL:', '/DRL:' {
			i = handle_session_command(cmd, args, i)
		}
		'/DWH', '/DAWH', '/DWC', '/DAWC', '/LOCKW', '/DWL', '/DAWL', '/DFL', '/DAFL', '/DWR',
		'/DAWR', '/DFR', '/DAFR', '/DWS', '/DAWS', '/DWNP', '/DHFS', '/DAHFS', '/DAFS', '/DFS',
		'/DESR', '/DESS' {
			handle_power_command(cmd, args, i)
			i++
		}
		'/SHUTDOWNINIT' {
			i = handle_shutdown_init(args, i)
		}
		'/SHUTDOWNABORT' {
			i = handle_shutdown_abort(args, i)
		}
		'/MSG', '/MSC', '/MSR', '/MSN', '/MSY', '/MSRC', '/MSIG', '/MSIC', '/MSIY' {
			mut_app, i = handle_message_box(mut_app, cmd, args, i)
		}
		'/MSSA' {
			if i + 1 < args.len {
				i++
				session_spec := args[i]
				send_to_session(session_spec)
			}
			i++
		}
		'/CAXCAPT' {
			if i + 1 < args.len {
				i++
				mut_app.caption = expand_variables(args[i])
			}
			i++
		}
		'/MSWT', '/MSWC', '/MSWU' {
			handle_message_window(cmd, args, i)
			i++
		}
		'/TELL' {
			if i + 1 < args.len {
				i++
				timeout_str := args[i]
				timeout := parse_int(timeout_str)
				if i + 1 < args.len {
					i++
					text := expand_variables(args[i])
					show_tell_window(text, timeout)
				}
			}
			i++
		}
		'/TELT' {
			if i + 1 < args.len {
				i++
				timeout_str := args[i]
				timeout := parse_int(timeout_str)
				if i + 1 < args.len {
					i++
					text := expand_variables(args[i])
					show_tell_window_with_countdown(text, timeout)
				}
			}
			i++
		}
		'/OSDTEXT', '/OSDRTF', '/OSDFILE', '/OSDRICHFILE', '/OSDTOP', '/OSDRECYCLE' {
			mut_app, i = handle_osd_command(mut_app, cmd, args, i)
		}
		'/CLASSCLOSE' {
			if i + 1 < args.len {
				i++
				class_pattern := args[i]
				close_windows_by_class(class_pattern)
			}
			i++
		}
		'/CAXLIST' {
			list_cax_instances()
			i++
		}
		'/WNC', '/WNT', '/WNH', '/WNS', '/WND', '/WNE', '/WNM', '/WNX', '/WNR', '/WNN', '/WNZT',
		'/WNZN', '/WNZA', '/WNZB', '/WNZM', '/WNWESH', '/WNWETH', '/WNWESS', '/WNWETS' {
			i = handle_window_command(cmd, args, i)
		}
		'/WINLIST', '/WINLISTA' {
			list_windows(cmd == '/WINLISTA')
			i++
		}
		'/WINPRIO1', '/WINPRIO2', '/WINPRIO3', '/WINPRIO4', '/WINPRIO5', '/WINPRIO6' {
			if i + 1 < args.len {
				i++
				window_name := args[i]
				priority := int(cmd[8] - `0`)
				set_window_priority(window_name, priority)
			}
			i++
		}
		'/WINTRANSP' {
			if i + 1 < args.len {
				i++
				transparency_str := args[i]
				transparency := parse_int(transparency_str)
				if i + 1 < args.len {
					i++
					window_pattern := args[i]
					set_window_transparency(window_pattern, u8(transparency))
				}
			}
			i++
		}
		'/WINTRCL' {
			if i + 1 < args.len {
				i++
				color_str := args[i]
				if i + 1 < args.len {
					i++
					window_pattern := args[i]
					set_window_color_transparent(window_pattern, color_str)
				}
			}
			i++
		}
		'/WINCLOSE' {
			if i + 1 < args.len {
				i++
				pattern := expand_variables(args[i])
				close_windows_by_title(pattern)
			}
			i++
		}
		'/WINDESTROY' {
			if i + 1 < args.len {
				i++
				pattern := expand_variables(args[i])
				destroy_windows_by_title(pattern)
			}
			i++
		}
		'/CLASSPRIO1', '/CLASSPRIO2', '/CLASSPRIO3', '/CLASSPRIO4', '/CLASSPRIO5', '/CLASSPRIO6' {
			if i + 1 < args.len {
				i++
				class_name := args[i]
				priority := int(cmd[10] - `0`)
				set_class_priority(class_name, priority)
			}
			i++
		}
		'/CLASSTRANSP' {
			if i + 1 < args.len {
				i++
				transparency_str := args[i]
				transparency := parse_int(transparency_str)
				if i + 1 < args.len {
					i++
					class_name := args[i]
					set_class_transparency(class_name, u8(transparency))
				}
			}
			i++
		}
		'/CLASSTRCL' {
			if i + 1 < args.len {
				i++
				color_str := args[i]
				if i + 1 < args.len {
					i++
					class_name := args[i]
					set_class_color_transparent(class_name, color_str)
				}
			}
			i++
		}
		'/CLASSDESTROY' {
			if i + 1 < args.len {
				i++
				pattern := args[i]
				destroy_windows_by_class(pattern)
			}
			i++
		}
		'/WINMSGSEND', '/WINMSGPOST' {
			if i + 4 < args.len {
				i++
				window_name := args[i]
				i++
				msg_str := args[i]
				i++
				wparam_str := args[i]
				i++
				lparam_str := args[i]
				msg := parse_int(msg_str)
				wparam := parse_uint(wparam_str)
				lparam := parse_int(lparam_str)
				if cmd == '/WINMSGSEND' {
					send_window_message(window_name, u32(msg), wparam, lparam)
				} else {
					post_window_message(window_name, u32(msg), wparam, lparam)
				}
			}
			i++
		}
		'/CLASSMSGSEND', '/CLASSMSGPOST' {
			if i + 4 < args.len {
				i++
				class_name := args[i]
				i++
				msg_str := args[i]
				i++
				wparam_str := args[i]
				i++
				lparam_str := args[i]
				msg := parse_int(msg_str)
				wparam := parse_uint(wparam_str)
				lparam := parse_int(lparam_str)
				if cmd == '/CLASSMSGSEND' {
					send_class_message(class_name, u32(msg), wparam, lparam)
				} else {
					post_class_message(class_name, u32(msg), wparam, lparam)
				}
			}
			i++
		}
		'/PROP' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				show_properties(file_path)
			}
			i++
		}
		'/DDEL', '/DEL', '/REM', '/DREM' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				delete_file_or_dir(file_path, cmd)
			}
			i++
		}
		'/CPY', '/CPA', '/CPD', '/CPH' {
			if i + 2 < args.len {
				i++
				source := expand_variables(args[i])
				i++
				target := expand_variables(args[i])
				copy_file_or_dir(source, target, cmd)
			}
			i++
		}
		'/MVE', '/MVA', '/MVD', '/MVH' {
			if i + 2 < args.len {
				i++
				source := expand_variables(args[i])
				i++
				target := expand_variables(args[i])
				move_file_or_dir(source, target, cmd)
			}
			i++
		}
		'/RNM', '/RNA', '/RND', '/RNH' {
			if i + 2 < args.len {
				i++
				old_name := expand_variables(args[i])
				i++
				new_name := expand_variables(args[i])
				rename_file_or_dir(old_name, new_name, cmd)
			}
			i++
		}
		'/MKD' {
			if i + 1 < args.len {
				i++
				dir_path := expand_variables(args[i])
				create_directory(dir_path)
			}
			i++
		}
		'/NETADD' {
			if i + 2 < args.len {
				i++
				remote := args[i]
				i++
				local := args[i]
				add_network_connection(remote, local)
			}
			i++
		}
		'/NETDEL' {
			if i + 1 < args.len {
				i++
				connection := args[i]
				delete_network_connection(connection)
			}
			i++
		}
		'/NETMAP' {
			i = handle_net_map(args, i)
		}
		'/REPLACE' {
			if i + 2 < args.len {
				i++
				source_file := expand_variables(args[i])
				i++
				new_name := expand_variables(args[i])
				replace_file_on_reboot(source_file, new_name)
			}
			i++
		}
		'/HARDLINK' {
			if i + 2 < args.len {
				i++
				new_file := expand_variables(args[i])
				i++
				existing_file := expand_variables(args[i])
				create_hard_link(new_file, existing_file)
			}
			i++
		}
		'/DSKEJ:', '/DSKFEJ:' {
			if i + 1 < args.len {
				i++
				drive := args[i]
				eject_drive(drive, cmd == '/DSKFEJ:')
			}
			i++
		}
		'/DSKCL:', '/DSKFCL:' {
			if i + 1 < args.len {
				i++
				drive := args[i]
				close_drive(drive, cmd == '/DSKFCL:')
			}
			i++
		}
		'/DSKLCK:', '/DSKUNL:' {
			if i + 1 < args.len {
				i++
				drive := args[i]
				if cmd == '/DSKLCK:' {
					lock_drive_removal(drive)
				} else {
					unlock_drive_removal(drive)
				}
			}
			i++
		}
		'/SUBST' {
			if i + 2 < args.len {
				i++
				drive := args[i]
				i++
				path := expand_variables(args[i])
				substitute_drive(drive, path, false)
			}
			i++
		}
		'/SUBSTR' {
			if i + 2 < args.len {
				i++
				drive := args[i]
				i++
				path := expand_variables(args[i])
				substitute_drive(drive, path, true)
			}
			i++
		}
		'/DSUBST' {
			if i + 1 < args.len {
				i++
				drive := args[i]
				delete_substitution(drive, '')
			}
			i++
		}
		'/DSUBSTE' {
			if i + 2 < args.len {
				i++
				drive := args[i]
				i++
				path := expand_variables(args[i])
				delete_substitution(drive, path)
			}
			i++
		}
		'/WAITDIRC', '/WAITDIRSC' {
			wait_for_directory_change(cmd == '/WAITDIRSC')
			i++
		}
		'/DRVLIST' {
			list_drives()
			i++
		}
		'/GETNETUSER' {
			if i + 1 < args.len {
				i++
				resource := args[i]
				get_network_user(resource)
			}
			i++
		}
		'/MD5FILE' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				mut output_dir := '-'
				if i + 1 < args.len {
					output_dir = expand_variables(args[i + 1])
					i++
				}
				calculate_md5(file_path, output_dir)
			}
			i++
		}
		'/SHA1FILE' {
			if i + 1 < args.len {
				i++
				file_path := expand_variables(args[i])
				mut output_dir := '-'
				if i + 1 < args.len {
					output_dir = expand_variables(args[i + 1])
					i++
				}
				calculate_sha1(file_path, output_dir)
			}
			i++
		}
		'/NETGETF', '/NETGETFH' {
			if i + 1 < args.len {
				i++
				url := args[i]
				mut local_name := ''
				if i + 1 < args.len {
					local_name = expand_variables(args[i + 1])
					i++
				}
				download_file(url, local_name, cmd == '/NETGETFH')
			}
			i++
		}
		'/VERBOSEN', '/VERBOSE0', '/VERBOSE1' {
			mut_app.verbose_level = match cmd {
				'/VERBOSEN' { -1 }
				'/VERBOSE0' { 0 }
				'/VERBOSE1' { 1 }
				else { 0 }
			}
			i++
		}
		'/FILEOF_NOSECATTR', '/FILEOF_NOCONELEM', '/FILEOF_NORECURSION', '/FILEOF_FILESONLY' {
			set_file_flag(cmd)
			i++
		}
		'/NETFLAG_ZERO', '/NETFLAG_ASK', '/NETFLAG_UPDPRO', '/NETFLAG_UPDREC', '/NETFLAG_CONTMP',
		'/NETFLAG_CONINT', '/NETFLAG_PROMPT', '/NETFLAG_REDIRECT', '/NETFLAG_CURMED',
		'/NETFLAG_CMDLINE', '/NETFLAG_SAVECRED', '/NETFLAG_RESETCRED' {
			set_net_flag(cmd)
			i++
		}
		'/HELP', '-H', '-HELP', '/H' {
			show_help()
			i++
		}
		'/VERSION', '-V', '-VERSION' {
			println('${app_name} version ${version}')
			i++
		}
		else {
			if mut_app.verbose_level >= 0 {
				eprintln('Unknown command: ${cmd}')
			}
			i++
		}
	}

	return mut_app, i
}

// ============================================================================
// Helper Functions
// ============================================================================

fn parse_int(s string) int {
	return s.int()
}

fn parse_uint(s string) int {
	return s.int()
}

// ============================================================================
// Variable Expansion
// ============================================================================

fn expand_variables(text string) string {
	mut result := text
	mut start := 0

	for {
		// Find %! pattern
		found_start := false
		found_end := false
		start_idx := 0
		end_idx := 0

		// Manual search for %!
		for j := start; j < result.len - 1; j++ {
			if result[j] == `%` && result[j + 1] == `!` {
				start_idx = j
				found_start = true
				break
			}
		}

		if !found_start {
			break
		}

		// Find !%
		for j := start_idx + 2; j < result.len - 1; j++ {
			if result[j] == `!` && result[j + 1] == `%` {
				end_idx = j
				found_end = true
				break
			}
		}

		if !found_end {
			break
		}

		var_name := result[start_idx + 2..end_idx]
		var_value := get_variable_value(var_name)

		result = result[..start_idx] + var_value + result[end_idx + 2..]
		start = start_idx + var_value.len
	}

	return result
}

fn get_variable_value(var_name string) string {
	now := time.now()
	match var_name {
		'TICK' {
			return time.ticks().str()
		}
		'HTICK' {
			return '${time.ticks():08x}'
		}
		'DTNOW' {
			return '${time.ticks() / 86400000:010x}'
		}
		'TTICK' {
			ticks := time.ticks()
			days := ticks / (24 * 60 * 60 * 1000)
			hours := (ticks % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000)
			minutes := (ticks % (60 * 60 * 1000)) / (60 * 1000)
			seconds := (ticks % (60 * 1000)) / 1000
			return '${days}d ${hours:02d}:${minutes:02d}:${seconds:02d}'
		}
		'CLOCK' {
			return '${now.hour:02d}:${now.minute:02d}:${now.second:02d}'
		}
		'TIME' {
			return '${now.hour:02d}-${now.minute:02d}-${now.second:02d}'
		}
		'T100' {
			return '${now.hour:02d}:${now.minute:02d}:${now.second:02d}'
		}
		'HOUR' {
			return '${now.hour:02d}'
		}
		'MIN' {
			return '${now.minute:02d}'
		}
		'SEC' {
			return '${now.second:02d}'
		}
		'DATE' {
			return '${now.year}-${now.month:02d}-${now.day:02d}'
		}
		'YEAR' {
			return '${now.year}'
		}
		'MON' {
			return '${now.month:02d}'
		}
		'DAY' {
			return '${now.day:02d}'
		}
		'DAYN' {
			return now.format()
		}
		'MONN' {
			return now.format()
		}
		'FMEM' {
			return get_free_memory().str()
		}
		'FMEMX' {
			return get_free_memory_high_res().str()
		}
		'FMEMP' {
			return get_free_memory_percent().str()
		}
		'CLIPBRD' {
			return get_clipboard_text()
		}
		'SWDESK' {
			return get_desktop_window_handle().str()
		}
		'SWSTART' {
			return get_start_button_handle().str()
		}
		'SWTRAY' {
			return get_system_tray_handle().str()
		}
		'UNAME' {
			return os.user_os()
		}
		'CNAME' {
			return os.hostname()
		}
		'IPADS' {
			return get_ip_addresses()
		}
		'CPUSPD' {
			return get_cpu_speed().str()
		}
		'CPUPERC' {
			return get_cpu_usage().str()
		}
		'PWRSTATE' {
			return get_power_state()
		}
		'BATTERY' {
			return get_battery_status()
		}
		'BATLIFE' {
			return get_battery_life()
		}
		'CDRIVE' {
			return os.getwd()[0..1]
		}
		'CDIR' {
			return os.getwd()
		}
		'SDRIVE' {
			return os.args[0][0..1]
		}
		'SDIR' {
			return os.dir(os.args[0])
		}
		'FILE:' {
			if var_name.len > 5 {
				file_path := var_name[5..]
				return get_first_line_from_file(file_path)
			}
			return ''
		}
		else {
			if var_name.starts_with('##') {
				return get_registry_value(var_name[2..])
			}
			return os.getenv(var_name)
		}
	}
}

// ============================================================================
// Help Display
// ============================================================================

fn show_help() {
	println('CAX - Comandiux for V Language version ${version}')
	println('')
	println('Usage: v run main.v [command] [parameters]')
	println('')
	println('General: /??? /BEEP /BEPL /WAPL /MVOLUME /MIXERS /SAVER /ENSAVER /DISSAVER')
	println('Clipboard: /SETCLIP /CLIPTOFILE /CLIPFROMFILE /KEYBSEND /KEYBFROMFILE')
	println('Wait: /WAIT /VWAIT /CYCLE /REPEAT /XTIMES /UNTIL /HOTKEY')
	println('Process: /RUN /RUA /RUM /RUH /RUX /PRCLIST /KILLPRC /KILLALL /KILLID')
	println('Service: /SVCLIST /SVCSTOP /SVCSTART /SVC~I /SVC~U')
	println('Device: /DEVLIST /DEVLICL /DEVEJIN /DEVDSIN /DEVENIN')
	println('Power: /DWR /DWC /DWL /DWS /DWH /LOCKW')
	println('Message: /MSG /MSC /MSY /MSN /MSIG /MSIC /MSIY')
	println('Window: /WNC /WINLIST /WINCLOSE /CLASSCLOSE')
	println('File: /CPY /MVE /DEL /MKD /DRVLIST')
	println('OSD: /OSDTEXT /OSDRTF /OSDFILE')
	println('Variables: %!CLOCK!% %!DATE!% %!UNAME!% %!CDIR!%')
	println('')
	println('For more: http://comandiux.scot.sk')
}

// ============================================================================
// Stub Implementations
// ============================================================================

fn beep() {
	println('[BEEP]')
}

fn play_default_beep() {
	println('[BEPL]')
}

fn play_wav_file(wav_file string) {
	println('[WAPL] ${wav_file}')
}

fn set_master_volume(volume int, mixer_idx int) {
	println('[MVOLUME] ${volume}')
}

fn list_mixers() {
	println('[MIXERS]')
}

fn run_screen_saver() {
	println('[SAVER]')
}

fn enable_screen_saver() {
	println('[ENSAVER]')
}

fn disable_screen_saver() {
	println('[DISSAVER]')
}

fn show_desktop() {
	println('[SHOWDESK]')
}

fn restore_desktop() {
	println('[RESTDESK]')
}

fn show_cpuid() {
	println('[CPUID]')
}

fn set_num_lock(on bool) {
	println('[NMLO]')
}

fn set_system_modal() {
	println('[MODAL]')
}

fn write_now_file(file_path string, text string) {
	now := time.now()
	content := '${now.year}-${now.month:02d}-${now.day:02d} ${now.hour:02d}:${now.minute:02d}:${now.second:02d} ${text}\n'
	os.write_file(file_path, content) or {
		eprintln('Error writing to file: ${file_path}')
		return
	}
	println('[NOW] Written to ${file_path}')
}

fn turn_monitor_off() {
	println('[MOFF!]')
}

fn turn_monitor_on() {
	println('[MON!]')
}

fn wait_for_hotkey(hotkey_spec string) {
	println('[HOTKEY] ${hotkey_spec}')
}

fn wait_until_time(time_spec string) {
	println('[UNTIL] ${time_spec}')
}

fn show_wait_window(text string, timeout int) {
	println('[VWAIT] ${text}')
}

fn free_memory(percent int) {
	println('[MEMFREE] ${percent}%')
}

fn create_manifest_file() {
	println('[.MANIFEST]')
}

fn register_exe() {
	println('[REGISTEREXE]')
}

fn run_program(app string, verb string, priority int, wait bool) {
	println('[RUN] ${app}')
}

fn run_program_as_admin(app string) {
	println('[RUA] ${app}')
}

fn run_program_minimized(app string) {
	println('[RUM] ${app}')
}

fn run_program_hidden(app string) {
	println('[RUH] ${app}')
}

fn run_program_maximized(app string) {
	println('[RUX] ${app}')
}

fn run_as_user(user_name string, domain string, password string, program string) {
	println('[ASUSER] ${user_name}')
}

fn list_processes() {
	println('[PRCLIST]')
}

fn list_processes_with_modules() {
	println('[PRCMODLIST]')
}

fn scan_processes() {
	println('[PRCSCAN]')
}

fn set_process_priority(process_name string, priority int) {
	println('[PRCPRIO${priority}] ${process_name}')
}

fn kill_process(process_name string, exit_code int) {
	println('[KILLPRC] ${process_name}')
}

fn kill_all_processes(pattern string) {
	println('[KILLALL] ${pattern}')
}

fn kill_last_process(pattern string) {
	println('[KILLLAST] ${pattern}')
}

fn kill_process_by_id(process_id u32) {
	println('[KILLID] ${process_id}')
}

fn kill_processes_by_user(user_pattern string) {
	println('[KILLUSER] ${user_pattern}')
}

fn handle_service_command(app AppState, args []string, idx int) (AppState, int) {
	mut i := idx
	mut mut_app := app
	cmd := args[i].to_upper()
	mut service_name := 'Comandiux'
	mut display_name := 'Comandiux Service'

	mut j := i + 1
	for j < args.len {
		arg := args[j].to_upper()
		if arg.starts_with('/SVC~NAME:') {
			service_name = args[j]['SVC~NAME:'.len..]
			j++
		} else if arg.starts_with('/SVC~DISP:') {
			display_name = args[j]['SVC~DISP:'.len..]
			j++
		} else {
			break
		}
	}
	i = j

	match cmd {
		'/SVC~I' { install_service(service_name, display_name, false) }
		'/SVC~IA' { install_service(service_name, display_name, true) }
		'/SVC~R' { run_as_service() }
		'/SVC~U' { uninstall_service(service_name) }
		else {}
	}

	return mut_app, i
}

fn install_service(name string, display_name string, auto_start bool) {
	println('[SVC~I] ${name}')
}

fn run_as_service() {
	println('[SVC~R]')
}

fn uninstall_service(name string) {
	println('[SVC~U] ${name}')
}

fn list_services() {
	println('[SVCLIST]')
}

fn list_services_only() {
	println('[SVCSVCLIST]')
}

fn list_drivers_only() {
	println('[SVCDRVLIST]')
}

fn stop_service(name string) {
	println('[SVCSTOP] ${name}')
}

fn start_service(name string) {
	println('[SVCSTART] ${name}')
}

fn list_devices(device_class string) {
	println('[DEVLIST]')
}

fn eject_device(cmd string, device_id string) {
	println('[${cmd}] ${device_id}')
}

fn disable_device(cmd string, device_id string) {
	println('[${cmd}] ${device_id}')
}

fn enable_device(cmd string, device_id string) {
	println('[${cmd}] ${device_id}')
}

fn handle_session_command(cmd string, args []string, idx int) int {
	mut i := idx
	if i + 1 < args.len {
		i++
		session_spec := args[i]
		println('[${cmd}] ${session_spec}')
	}
	i++
	return i
}

fn handle_power_command(cmd string, args []string, i int) {
	ask := cmd.contains('DA')
	a_prefix := if ask { 'A' } else { '' }
	a_suffix := if ask { ' (with ask)' } else { '' }

	match cmd {
		'/DWH', '/DAWH' { println('[D${a_prefix}WH] Hibernate${a_suffix}') }
		'/DWC', '/DAWC' { println('[D${a_prefix}WC] Shutdown${a_suffix}') }
		'/LOCKW' { println('[LOCKW]') }
		'/DWL', '/DAWL' { println('[D${a_prefix}WL] Log off${a_suffix}') }
		'/DWR', '/DAWR' { println('[D${a_prefix}WR] Reboot${a_suffix}') }
		'/DWS', '/DAWS' { println('[D${a_prefix}WS] Suspend${a_suffix}') }
		'/DESR' { println('[DESR] Emergency reboot!') }
		'/DESS' { println('[DESS] Emergency shutdown!') }
		else { println('[${cmd}]') }
	}
}

fn handle_shutdown_init(args []string, idx int) int {
	mut i := idx
	if i + 4 < args.len {
		i++
		machine := args[i]
		i++
		timeout_str := args[i]
		i++
		message := args[i]
		i++
		force_str := args[i]
		i++
		reboot_str := args[i]
		_ = force_str
		_ = reboot_str
		println('[SHUTDOWNINIT] ${machine} ${timeout_str} "${message}"')
	}
	i++
	return i
}

fn handle_shutdown_abort(args []string, idx int) int {
	mut i := idx
	if i + 1 < args.len {
		i++
		machine := args[i]
		println('[SHUTDOWNABORT] ${machine}')
	}
	i++
	return i
}

fn handle_message_box(app AppState, cmd string, args []string, idx int) (AppState, int) {
	mut i := idx
	mut mut_app := app
	if i + 1 < args.len {
		i++
		text := expand_variables(args[i])

		flags := match cmd {
			'/MSG', '/MSIG' { mb_ok }
			'/MSC', '/MSIC' { mb_okcancel }
			'/MSR' { mb_abortretryignore }
			'/MSN' { mb_yesnocancel }
			'/MSY', '/MSIY' { mb_yesno }
			'/MSRC' { mb_retrycancel }
			else { mb_ok }
		}

		caption := if mut_app.caption != '' { mut_app.caption } else { app_name }
		result := show_message_box(mut_app, flags, caption, text)

		should_continue := match cmd {
			'/MSIG', '/MSIC', '/MSIY' {
				if cmd == '/MSIG' || cmd == '/MSIC' {
					result == idok
				} else {
					result == idyes
				}
			}
			else {
				true
			}
		}

		if !should_continue {
			exit(result)
		}

		println('[${cmd}] Result: ${result}')
	}
	i++
	return mut_app, i
}

fn show_message_box(app AppState, flags int, caption string, text string) int {
	println('[MSG] ${caption}: ${text}')
	return idok
}

fn send_to_session(session_spec string) {
	println('[MSSA] ${session_spec}')
}

fn handle_message_window(cmd string, args []string, i int) {
	if i + 1 < args.len {
		text := expand_variables(args[i + 1])
		println('[${cmd}] ${text}')
	}
}

fn show_tell_window(text string, timeout int) {
	println('[TELL] ${text}')
}

fn show_tell_window_with_countdown(text string, timeout int) {
	println('[TELT] ${text}')
}

fn handle_osd_command(app AppState, cmd string, args []string, idx int) (AppState, int) {
	mut i := idx
	mut mut_app := app
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
				mut_app.osd_position = parse_int(args[i])
			}
		}
		'/OSDRECYCLE' {
			mut_app.osd_recycle = true
		}
		else {}
	}
	i++
	return mut_app, i
}

fn list_cax_instances() {
	println('[CAXLIST]')
}

fn handle_window_command(cmd string, args []string, idx int) int {
	mut i := idx
	if i + 2 < args.len {
		i++
		class_name := args[i]
		i++
		window_name := args[i]
		println('[${cmd}] ${class_name} ${window_name}')
	} else if i + 1 < args.len {
		i++
		println('[${cmd}] ${args[i]}')
	} else {
		println('[${cmd}]')
	}
	i++
	return i
}

fn list_windows(include_no_caption bool) {
	suffix := if include_no_caption { 'A' } else { '' }
	println('[WINLIST${suffix}]')
}

fn set_window_priority(window_name string, priority int) {
	println('[WINPRIO${priority}] ${window_name}')
}

fn set_window_transparency(window_pattern string, transparency u8) {
	println('[WINTRANSP] ${window_pattern}')
}

fn set_window_color_transparent(window_pattern string, color_str string) {
	println('[WINTRCL] ${window_pattern}')
}

fn close_windows_by_title(pattern string) {
	println('[WINCLOSE] ${pattern}')
}

fn destroy_windows_by_title(pattern string) {
	println('[WINDESTROY] ${pattern}')
}

fn set_class_priority(class_name string, priority int) {
	println('[CLASSPRIO${priority}] ${class_name}')
}

fn set_class_transparency(class_name string, transparency u8) {
	println('[CLASSTRANSP] ${class_name}')
}

fn set_class_color_transparent(class_name string, color_str string) {
	println('[CLASSTRCL] ${class_name}')
}

fn close_windows_by_class(pattern string) {
	println('[CLASSCLOSE] ${pattern}')
}

fn destroy_windows_by_class(pattern string) {
	println('[CLASSDESTROY] ${pattern}')
}

fn send_window_message(window_name string, msg u32, wparam int, lparam int) {
	println('[WINMSGSEND] ${window_name}')
}

fn post_window_message(window_name string, msg u32, wparam int, lparam int) {
	println('[WINMSGPOST] ${window_name}')
}

fn send_class_message(class_name string, msg u32, wparam int, lparam int) {
	println('[CLASSMSGSEND] ${class_name}')
}

fn post_class_message(class_name string, msg u32, wparam int, lparam int) {
	println('[CLASSMSGPOST] ${class_name}')
}

fn show_properties(file_path string) {
	println('[PROP] ${file_path}')
}

fn delete_file_or_dir(file_path string, cmd string) {
	println('[${cmd}] ${file_path}')
}

fn copy_file_or_dir(source string, target string, cmd string) {
	println('[${cmd}] ${source} -> ${target}')
}

fn move_file_or_dir(source string, target string, cmd string) {
	println('[${cmd}] ${source} -> ${target}')
}

fn rename_file_or_dir(old_name string, new_name string, cmd string) {
	println('[${cmd}] ${old_name} -> ${new_name}')
}

fn create_directory(dir_path string) {
	println('[MKD] ${dir_path}')
}

fn add_network_connection(remote string, local string) {
	println('[NETADD] ${remote} -> ${local}')
}

fn delete_network_connection(connection string) {
	println('[NETDEL] ${connection}')
}

fn handle_net_map(args []string, idx int) int {
	mut i := idx
	if i + 5 < args.len {
		i++
		remote_name := args[i]
		i++
		local_name := args[i]
		println('[NETMAP] ${remote_name} -> ${local_name}')
	}
	i++
	return i
}

fn replace_file_on_reboot(source_file string, new_name string) {
	println('[REPLACE] ${source_file}')
}

fn create_hard_link(new_file string, existing_file string) {
	println('[HARDLINK] ${new_file}')
}

fn eject_drive(drive string, force bool) {
	prefix := if force { 'DSKFEJ:' } else { 'DSKEJ:' }
	println('[${prefix}] ${drive}')
}

fn close_drive(drive string, force bool) {
	prefix := if force { 'DSKFCL:' } else { 'DSKCL:' }
	println('[${prefix}] ${drive}')
}

fn lock_drive_removal(drive string) {
	println('[DSKLCK:] ${drive}')
}

fn unlock_drive_removal(drive string) {
	println('[DSKUNL:] ${drive}')
}

fn substitute_drive(drive string, path string, raw bool) {
	prefix := if raw { 'SUBSTR' } else { 'SUBST' }
	println('[${prefix}] ${drive} = ${path}')
}

fn delete_substitution(drive string, path string) {
	suffix := if path != '' { 'E' } else { '' }
	println('[DSUBST${suffix}] ${drive}')
}

fn wait_for_directory_change(include_subdirs bool) {
	suffix := if include_subdirs { 'SC' } else { 'C' }
	println('[WAITDIR${suffix}]')
}

fn list_drives() {
	println('[DRVLIST]')
}

fn get_network_user(resource string) {
	println('[GETNETUSER] ${resource}')
}

fn calculate_md5(file_path string, output_dir string) {
	println('[MD5FILE] ${file_path}')
}

fn calculate_sha1(file_path string, output_dir string) {
	println('[SHA1FILE] ${file_path}')
}

fn download_file(url string, local_name string, hidden bool) {
	prefix := if hidden { 'NETGETH' } else { 'NETGETF' }
	println('[${prefix}] ${url}')
}

fn set_clipboard_text(text string) {
	println('[SETCLIP] ${text.len} chars')
}

fn get_clipboard_text() string {
	return ''
}

fn clipboard_to_file(file_path string) {
	println('[CLIPTOFILE] ${file_path}')
}

fn clipboard_from_file(file_path string) {
	println('[CLIPFROMFILE] ${file_path}')
}

fn send_keyboard_input(text string) {
	println('[KEYBSEND] ${text}')
}

fn send_keyboard_from_file(file_path string) {
	println('[KEYBFROMFILE] ${file_path}')
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

fn get_first_line_from_file(file_path string) string {
	return os.read_file(file_path) or { '' }
}

fn get_registry_value(reg_path string) string {
	return ''
}

fn set_file_flag(cmd string) {
	println('[FILEFLAG] ${cmd}')
}

fn set_net_flag(cmd string) {
	println('[NETFLAG] ${cmd}')
}
