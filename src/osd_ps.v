// CAX - OSD Implementation using PowerShell
// This creates a semi-transparent overlay window

module main

import os

pub fn show_osd(text string, timeout_ms int) {
	// Create PowerShell script to temp file
	temp_ps := os.temp_dir() + '/cax_osd.ps1'
	
	ps_script := []string{
		'param(',
		'    [string]$Text,',
		'    [int]$Timeout',
		')',
		'',
		'Add-Type -AssemblyName System.Windows.Forms',
		'Add-Type -AssemblyName System.Drawing',
		'',
		'# Create form',
		'$form = New-Object System.Windows.Forms.Form',
		'$form.Text = "CAX OSD"',
		'$form.StartPosition = "Manual"',
		'$form.FormBorderStyle = "None"',
		'$form.TopMost = $true',
		'$form.ShowInTaskbar = $false',
		'$form.BackColor = [System.Drawing.Color]::Black',
		'$form.Opacity = 0.85',
		'$form.TransparencyKey = [System.Drawing.Color]::Black',
		'',
		'# Get screen dimensions',
		'$screen = [System.Windows.Forms.Screen]::PrimaryScreen',
		'$screenWidth = $screen.Bounds.Width',
		'$screenHeight = $screen.Bounds.Height',
		'',
		'# Calculate position (bottom center)',
		'$formWidth = [int]($screenWidth * 0.6)',
		'$formHeight = 120',
		'$form.Left = [int](($screenWidth - $formWidth) / 2)',
		'$form.Top = $screenHeight - $formHeight - 100',
		'$form.Width = $formWidth',
		'$form.Height = $formHeight',
		'',
		'# Create label',
		'$label = New-Object System.Windows.Forms.Label',
		'$label.Text = $Text',
		'$label.AutoSize = $false',
		'$label.Dock = "Fill"',
		'$label.TextAlign = "MiddleCenter"',
		'$label.Font = New-Object System.Drawing.Font("Verdana", 48, [System.Drawing.FontStyle]::Bold)',
		'$label.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)',
		'$label.BackColor = [System.Drawing.Color]::Black',
		'',
		'$form.Controls.Add($label)',
		'',
		'# Show form',
		'$form.Show()',
		'',
		'# Wait for timeout',
		'Start-Sleep -Milliseconds $Timeout',
		'',
		'# Close',
		'$form.Close()',
		'$form.Dispose()',
	}
	
	content := ps_script.join('\n')
	os.write_file(temp_ps, content) or {
		eprintln('Failed to create OSD script')
		return
	}
	
	// Execute PowerShell with timeout
	os.execute('powershell -ExecutionPolicy Bypass -File "${temp_ps}" -Text "${text}" -Timeout ${timeout_ms}')
	
	// Cleanup
	os.remove(temp_ps) or {}
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
	show_osd(text, timeout)
	println('OSD closed')
}
