$content = Get-Content main.v -Raw

# Fix .int() or {} patterns - these should use if expressions
$content = $content -replace 'timeout := int\(timeout_str\.int\(\) or \{ 0 \}\)', 'mut timeout = 0`n`t`t`t`tif t := timeout_str.int() { timeout = t }'
$content = $content -replace 'app\.cycle_timeout = int\(timeout_str\.int\(\) or \{ 0 \}\)', 'app.cycle_timeout = 0`n`t`t`t`tif t := timeout_str.int() { app.cycle_timeout = t }'
$content = $content -replace 'app\.repeat_count = int\(repeat_str\.int\(\) or \{ 0 \}\)', 'app.repeat_count = 0`n`t`t`t`tif t := repeat_str.int() { app.repeat_count = t }'
$content = $content -replace 'app\.xtimes = int\(xtimes_str\.int\(\) or \{ 0 \}\)', 'app.xtimes = 0`n`t`t`t`tif t := xtimes_str.int() { app.xtimes = t }'
$content = $content -replace 'percent := int\(percent_str\.int\(\) or \{ 0 \}\)', 'mut percent = 0`n`t`t`t`tif t := percent_str.int() { percent = t }'
$content = $content -replace 'app\.priority = int\(prio_str\.int\(\) or \{ priority_normal \}\)', 'mut app.priority = priority_normal`n`t`t`t`tif t := prio_str.int() { app.priority = t }'
$content = $content -replace 'exit_code := int\(exit_code_str\.int\(\) or \{ 1 \}\)', 'mut exit_code = 1`n`t`t`t`tif t := exit_code_str.int() { exit_code = t }'
$content = $content -replace 'transparency := u8\(transparency_str\.int\(\) or \{ 255 \}\)', 'mut transparency = [u8]255`n`t`t`t`tif t := transparency_str.int() { transparency = [u8]t }'
$content = $content -replace 'msg := u32\(msg_str\.int\(\) or \{ 0 \}\)', 'mut msg = [u32]0`n`t`t`t`tif t := msg_str.int() { msg = [u32]t }'
$content = $content -replace 'wparam := usize\(wparam_str\.int\(\) or \{ 0 \}\)', 'mut wparam = 0`n`t`t`t`tif t := wparam_str.int() { wparam = t }'
$content = $content -replace 'lparam := isize\(lparam_str\.int\(\) or \{ 0 \}\)', 'mut lparam = 0`n`t`t`t`tif t := lparam_str.int() { lparam = t }'
$content = $content -replace 'app\.osd_position = int\(position_str\.int\(\) or \{ 20 \}\)', 'app.osd_position = 20`n`t`t`t`tif t := position_str.int() { app.osd_position = t }'
$content = $content -replace 'process_id := u32\(id_str\.int\(prefix: ''0x''\) or \{ id_str\.int\(\) or 0 \}\)', 'mut process_id = [u32]0`n`t`t`t`tif t := id_str.int(prefix: ''0x'') { process_id = [u32]t }'

Set-Content main.v -Value $content -NoNewline
Write-Host "Done"
