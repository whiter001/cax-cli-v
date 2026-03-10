// ============================================================================
// CAX Native OSD - 使用纯 V + Windows API 实现
// ============================================================================
// 功能：在屏幕底部显示半透明 OSD（On-Screen Display）
// 作者：CAX Team
// 版本：0.0.1
// 特点：
//   - 使用 Windows API 创建窗口（无需外部依赖）
//   - 半透明背景 + 绿色文字
//   - 屏幕底部居中显示
//   - 自动定时关闭
// 参数：
//   第一个参数：显示的文本
//   -t <秒数>：显示时间（秒），默认 5 秒
// ============================================================================

module main

import os

#flag windows -luser32 -lgdi32

fn C.CreateWindowExA(int, voidptr, voidptr, int, int, int, int, voidptr, voidptr, voidptr, voidptr, voidptr) voidptr
fn C.ShowWindow(voidptr, int) int
fn C.GetSystemMetrics(int) int
fn C.SetLayeredWindowAttributes(voidptr, int, int, int) int
fn C.GetModuleHandleA(voidptr) voidptr
fn C.GetDC(voidptr) voidptr
fn C.ReleaseDC(voidptr, voidptr) int
fn C.SetBkMode(voidptr, int) int
fn C.SetTextColor(voidptr, u32) int
fn C.TextOutA(voidptr, int, int, voidptr, int) int
fn C.Sleep(int)

const ws_ex_layered = 0x00080000
const ws_ex_toolwindow = 0x00000080
const ws_ex_topmost = 0x00000008

// ============================================================================
// 主函数 - 程序入口点
// ============================================================================
// 功能：解析命令行参数，创建 OSD 窗口并显示
// ============================================================================
fn main() {
    mut timeout_sec := 5
    mut text := 'OSD Test'
    
    args := os.args
    mut i := 1
    for i < args.len {
        if args[i] == '-t' && i + 1 < args.len {
            timeout_sec = args[i + 1].int()
            i += 2
        } else if args[i] == '-text' && i + 1 < args.len {
            text = args[i + 1]
            i += 2
        } else if args[i].len > 0 {
            text = args[i]
            i++
        } else {
            i++
        }
    }
    
    hinstance := voidptr(C.GetModuleHandleA(voidptr(0)))
    
    screen_width := C.GetSystemMetrics(0)
    screen_height := C.GetSystemMetrics(1)
    
    window_width := 400
    window_height := 100
    x := (screen_width - window_width) / 2
    y := screen_height - window_height - 50
    
    ex_style := ws_ex_layered | ws_ex_toolwindow | ws_ex_topmost
    
    ctext := unsafe { &u8(malloc(text.len + 1)) }
    for j := 0; j < text.len; j++ {
        unsafe { ctext[j] = text[j] }
    }
    unsafe { ctext[text.len] = 0 }
    
    hwnd := C.CreateWindowExA(
        ex_style,
        'STATIC'.str,
        ctext,
        0x80000000,
        x, y, window_width, window_height,
        voidptr(0), voidptr(0), hinstance, voidptr(0)
    )
    
    C.SetLayeredWindowAttributes(hwnd, 0, 180, 2)
    
    C.ShowWindow(hwnd, 5)
    
    hdc := C.GetDC(hwnd)
    C.SetBkMode(hdc, 1)
    C.SetTextColor(hdc, 0x0000FF00)
    C.TextOutA(hdc, 150, 40, ctext, text.len)
    C.ReleaseDC(hwnd, hdc)
    
    timeout_ms := timeout_sec * 1000
    mut elapsed := 0
    for elapsed < timeout_ms {
        C.Sleep(10)
        elapsed += 10
    }
    
    unsafe { free(ctext) }
}

fn C.malloc(int) voidptr
fn C.free(voidptr)
