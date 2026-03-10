param(
    [int]$TimeoutSec = 20,
    [string]$Text = "OSD Test"
)

$TimeoutMs = $TimeoutSec * 100

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form with transparency
$f = New-Object System.Windows.Forms.Form
$f.Text = "CAX OSD"
$f.StartPosition = 'Manual'
$f.FormBorderStyle = 'None'
$f.TopMost = $true
$f.ShowInTaskbar = $false
$f.BackColor = [System.Drawing.Color]::White
$f.TransparencyKey = [System.Drawing.Color]::White  # Make white background transparent
$f.Opacity = 1.0

# Get screen dimensions
$sw = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$sh = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# Calculate size and position (bottom center)
$fw = [int]($sw * 0.6)
$fh = 120
$f.Left = [int](($sw - $fw) / 2)
$f.Top = $sh - $fh - 100
$f.Width = $fw
$f.Height = $fh

# Create label with lime green text
$l = New-Object System.Windows.Forms.Label
$l.Text = $Text
$l.AutoSize = $false
$l.Dock = 'Fill'
$l.TextAlign = 'MiddleCenter'
$l.Font = New-Object System.Drawing.Font('Verdana', 48, [System.Drawing.FontStyle]::Bold)
$l.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)  # Lime green
$l.BackColor = [System.Drawing.Color]::White  # Same as form background for transparency

$f.Controls.Add($l)

# Show form
$f.Show()

# Wait for timeout
Start-Sleep -Milliseconds $TimeoutMs

# Cleanup
$f.Close()
$f.Dispose()
