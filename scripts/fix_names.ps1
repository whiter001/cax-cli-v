$content = Get-Content main.v -Raw
$content = $content -replace 'parseInt\(', 'parse_int('
$content = $content -replace 'parseUint\(', 'parse_uint('
$content = $content -replace 'parseFloat\(', 'parse_float('
Set-Content main.v -Value $content -NoNewline
Write-Host "Done"
