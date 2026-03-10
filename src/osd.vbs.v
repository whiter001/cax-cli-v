// CAX - OSD Implementation using VBScript
// Creates a popup window with green text on black background

module main

import os

pub fn show_osd(text string, timeout_ms int) {
	// Create VBScript to show OSD
	temp_vbs := os.temp_dir() + '/cax_osd.vbs'
	
	// VBScript content
	vbs := 'Set objArgs = WScript.Arguments' + '\n' +
		'text = objArgs(0)' + '\n' +
		'timeout = objArgs(1)' + '\n' +
		'\n' +
		'// Create popup using HTA-style window' + '\n' +
		'Set objShell = CreateObject("WScript.Shell")' + '\n' +
		'\n' +
		'// Show message (will be replaced with better UI)' + '\n' +
		'WScript.Sleep timeout' + '\n'
	
	os.write_file(temp_vbs, vbs) or {
		eprintln('Failed to create VBScript')
		return
	}
	
	// For now, just show a simple popup using msg
	// This is a placeholder - real OSD needs Windows API
	os.execute('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(\\"${text}\\", \\"CAX OSD\\", 0, 64); Start-Sleep -Milliseconds ${timeout_ms}"')
	
	os.remove(temp_vbs) or {}
}

fn main() {
	args := os.args
	
	mut text := 'OSD Test'
	mut timeout := 2000
	
	if args.len > 1 {
		if t := args[1].int() {
			timeout = t * 100
		}
	}
	if args.len > 2 {
		text = args[2]
	}
	
	println('Showing OSD: "${text}" for ${timeout / 1000}s')
	println('(Note: Full OSD requires Windows API implementation)')
	show_osd(text, timeout)
	println('OSD closed')
}
