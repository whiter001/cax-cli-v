# ============================================================================
# CAX OSD Display Script - PowerShell Implementation
# ============================================================================
# Function: Display semi-transparent OSD at screen bottom
# Features: Transparent background, lime green text, auto close

param(
    [int]$TimeoutSec = 20,
    [string]$Text = "OSD Test"
)

# Convert to milliseconds
$TimeoutMs = $TimeoutSec * 100

# Load .NET assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create OSD window
$f = New-Object System.Windows.Forms.Form
$f.Text = "CAX OSD"
$f.StartPosition = 'Manual'
$f.FormBorderStyle = 'None'
$f.TopMost = $true
$f.ShowInTaskbar = $false
$f.BackColor = [System.Drawing.Color]::White
$f.TransparencyKey = [System.Drawing.Color]::White
$f.Opacity = 1.0

# Get screen size
$sw = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$sh = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# Calculate OSD size and position
$fw = [int]($sw * 0.6)
$fh = 120
$f.Left = [int](($sw - $fw) / 2)
$f.Top = $sh - $fh - 100
$f.Width = $fw
$f.Height = $fh

# Create label
$l = New-Object System.Windows.Forms.Label
$l.Text = $Text
$l.AutoSize = $false
$l.Dock = 'Fill'
$l.TextAlign = 'MiddleCenter'
$l.Font = New-Object System.Drawing.Font('Verdana', 48, [System.Drawing.FontStyle]::Bold)
$l.ForeColor = [System.Drawing.Color]::FromArgb(50, 205, 50)  # Lime green
$l.BackColor = [System.Drawing.Color]::White
$f.Controls.Add($l)

# Show OSD
$f.Show()
Start-Sleep -Milliseconds $TimeoutMs
$f.Close()
$f.Dispose()
