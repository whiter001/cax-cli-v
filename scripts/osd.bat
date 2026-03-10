@echo off
REM CAX OSD Launcher - Simple Version
REM Usage: osd.bat [timeout_seconds] "text"

set TIMEOUT_SEC=%1
set TEXT=%2

if "%TIMEOUT_SEC%"=="" set TIMEOUT_SEC=20
if "%TEXT%"=="" set TEXT=OSD Test

set /a TIMEOUT_MS=TIMEOUT_SEC * 100

powershell -ExecutionPolicy Bypass -WindowStyle Hidden ^
  -Command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $f=New-Object System.Windows.Forms.Form; $f.StartPosition='Manual'; $f.FormBorderStyle='None'; $f.TopMost=$true; $f.ShowInTaskbar=$false; $f.BackColor=[System.Drawing.Color]::Black; $f.Opacity=0.9; $sw=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width; $sh=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height; $fw=[int]($sw*0.6); $fh=120; $f.Left=[int](($sw-$fw)/2); $f.Top=$sh-$fh-100; $f.Width=$fw; $f.Height=$fh; $l=New-Object System.Windows.Forms.Label; $l.Text='%TEXT%'; $l.AutoSize=$false; $l.Dock='Fill'; $l.TextAlign='MiddleCenter'; $l.Font=New-Object System.Drawing.Font('Verdana',48,[System.Drawing.FontStyle]::Bold); $l.ForeColor=[System.Drawing.Color]::FromArgb(0,255,0); $l.BackColor=[System.Drawing.Color]::Black; $f.Controls.Add($l); $f.Show(); Start-Sleep -Milliseconds %TIMEOUT_MS%; $f.Close(); $f.Dispose()"
