$content = Get-Content main.v -Raw

# Fix complex string interpolations
$content = $content -replace "\[DEVLIST\]\`\$\{if device_class != '' \{ ' class=\`\$\{device_class\}' \} else \{ '' \}\}\`'", '[DEVLIST] + (if device_class != '' { ' class=$device_class' } else { '' })'
$content = $content -replace "\[WINLIST\`\$\{if include_no_caption \{ 'A' \} else \{ '' \}\}\]", '[WINLIST' + (if include_no_caption { 'A' } else { '' }) + ']'

Set-Content main.v -Value $content -NoNewline
Write-Host "Done"
