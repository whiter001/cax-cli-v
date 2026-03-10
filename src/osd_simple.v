// CAX - Simple OSD Implementation using Windows API
// Run with: v run src/osd_simple.v

module main

#flag windows -lgdi32 -luser32

#include <windows.h>

// ============================================================================
// Types
// ============================================================================

type HWND = &void
type HDC = &void
type HBRUSH = &void
type HFONT = &void
type HGDIOBJ = &void
type COLORREF = u32
type BOOL = int
type LPVOID = &void
type LPCWSTR = &u16
type LRESULT = isize
type WPARAM = usize
type LPARAM = isize

// ============================================================================
// Constants
// ============================================================================

const (
	WS_POPUP               = 0x80000000
	WS_VISIBLE             = 0x10000000
	WS_EX_LAYERED          = 0x00080000
	WS_EX_TOPMOST          = 0x00000008
	SW_SHOWNORMAL          = 1
	WM_DESTROY             = 0x0002
	WM_PAINT               = 0x000F
	WM_TIMER               = 0x0113
	COLOR_KEY              = 0x00000000
	LWA_COLORKEY           = 0x00000002
	TRANSPARENT            = 1
	SM_CXSCREEN            = 0
	SM_CYSCREEN            = 1
	TMF_TRANSPARENT        = 0x00000001
	DT_SINGLELINE          = 0x00000020
	DT_CENTER              = 0x00000001
	DT_VCENTER             = 0x00000004
)

// ============================================================================
// Global Variables
// ============================================================================

mut (
	g_hwnd        HWND = &void(nil)
	g_text        string = ''
	g_timeout_ms  int = 2000
)

// ============================================================================
// Windows API Declarations
// ============================================================================

fn CreateWindowExA(dwExStyle u32, lpClassName &u8, lpWindowName &u8, 
    dwStyle u32, x int, y int, nWidth int, nHeight int, 
    hWndParent HWND, hMenu HWND, hInstance HWND, lpParam LPVOID) HWND {
	unsafe {
		return CreateWindowExA(dwExStyle, lpClassName, lpWindowName, 
            dwStyle, x, y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)
	}
}

fn DestroyWindow(hWnd HWND) BOOL {
	unsafe {
		return DestroyWindow(hWnd)
	}
}

fn ShowWindow(hWnd HWND, nCmdShow int) BOOL {
	unsafe {
		return ShowWindow(hWnd, nCmdShow)
	}
}

fn UpdateWindow(hWnd HWND) BOOL {
	unsafe {
		return UpdateWindow(hWnd)
	}
}

fn GetDC(hWnd HWND) HDC {
	unsafe {
		return GetDC(hWnd)
	}
}

fn ReleaseDC(hWnd HWND, hDC HDC) int {
	unsafe {
		return ReleaseDC(hWnd, hDC)
	}
}

fn DefWindowProcA(hWnd HWND, Msg u32, wParam WPARAM, lParam LPARAM) LRESULT {
	unsafe {
		return DefWindowProcA(hWnd, Msg, wParam, lParam)
	}
}

fn RegisterClassA(lpClassName &u8, lpfnWndProc &void, hInstance HWND, 
    hbrBackground HBRUSH) u16 {
	unsafe {
		return RegisterClassA(lpClassName, lpfnWndProc, hInstance, hbrBackground)
	}
}

fn GetSystemMetrics(nIndex int) int {
	unsafe {
		return GetSystemMetrics(nIndex)
	}
}

fn SetLayeredWindowAttributes(hWnd HWND, crKey COLORREF, bAlpha byte, dwFlags u32) BOOL {
	unsafe {
		return SetLayeredWindowAttributes(hWnd, crKey, bAlpha, dwFlags)
	}
}

fn SetTimer(hWnd HWND, nIDEvent WPARAM, uElapse u32, lpTimerFunc &void) WPARAM {
	unsafe {
		return SetTimer(hWnd, nIDEvent, uElapse, lpTimerFunc)
	}
}

fn KillTimer(hWnd HWND, nIDEvent WPARAM) BOOL {
	unsafe {
		return KillTimer(hWnd, nIDEvent)
	}
}

fn PostQuitMessage(nExitCode int) {
	unsafe {
		PostQuitMessage(nExitCode)
	}
}

fn GetLastError() u32 {
	unsafe {
		return GetLastError()
	}
}

fn GetModuleHandleA(lpModuleName &u8) HWND {
	unsafe {
		return GetModuleHandleA(lpModuleName)
	}
}

fn CreateSolidBrush(crColor COLORREF) HBRUSH {
	unsafe {
		return CreateSolidBrush(crColor)
	}
}

fn DeleteObject(hObject HGDIOBJ) BOOL {
	unsafe {
		return DeleteObject(hObject)
	}
}

fn CreateFontA(nHeight int, nWidth int, nEscapement int, nOrientation int, 
    fnWeight int, fdwItalic u32, fdwUnderline u32, fdwStrikeOut u32, 
    fdwCharSet u32, fdwOutputPrecision u32, fdwClipPrecision u32, 
    fdwQuality u32, fdwPitchAndFamily u32, lpszFace &u8) HFONT {
	unsafe {
		return CreateFontA(nHeight, nWidth, nEscapement, nOrientation, 
            fnWeight, fdwItalic, fdwUnderline, fdwStrikeOut, 
            fdwCharSet, fdwOutputPrecision, fdwClipPrecision, 
            fdwQuality, fdwPitchAndFamily, lpszFace)
	}
}

fn SelectObject(hdc HDC, hgdiobj HGDIOBJ) HGDIOBJ {
	unsafe {
		return SelectObject(hdc, hgdiobj)
	}
}

fn SetBkMode(hdc HDC, mode int) int {
	unsafe {
		return SetBkMode(hdc, mode)
	}
}

fn SetTextColor(hdc HDC, crColor COLORREF) COLORREF {
	unsafe {
		return SetTextColor(hdc, crColor)
	}
}

fn TextOutA(hdc HDC, x int, y int, lpString &u8, c int) BOOL {
	unsafe {
		return TextOutA(hdc, x, y, lpString, c)
	}
}

fn GetMessageA(lpMsg &void, hWnd HWND, wMsgFilterMin u32, wMsgFilterMax u32) i32 {
	unsafe {
		return GetMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax)
	}
}

fn TranslateMessage(lpMsg &void) BOOL {
	unsafe {
		return TranslateMessage(lpMsg)
	}
}

fn DispatchMessageA(lpMsg &void) LRESULT {
	unsafe {
		return DispatchMessageA(lpMsg)
	}
}

fn GetClientRect(hWnd HWND, lpRect &void) BOOL {
	unsafe {
		return GetClientRect(hWnd, lpRect)
	}
}

fn DrawTextA(hdc HDC, lpchText &u8, cchText int, lprc &void, format u32) int {
	unsafe {
		return DrawTextA(hdc, lpchText, cchText, lprc, format)
	}
}

fn Sleep(dwMilliseconds u32) {
	unsafe {
		Sleep(dwMilliseconds)
	}
}

// ============================================================================
// Window Procedure
// ============================================================================

fn wnd_proc(hWnd HWND, Msg u32, wParam WPARAM, lParam LPARAM) LRESULT {
	match Msg {
		WM_PAINT {
			hdc := GetDC(hWnd)
			
			// Lime green text (RGB: 0, 255, 0)
			SetTextColor(hdc, 0x0000FF00)
			SetBkMode(hdc, TRANSPARENT)
			
			// Create bold Verdana font, 48pt
			hfont := CreateFontA(
				-64, 0, 0, 0, 700, 0, 0, 0,
				0, 0, 0, 5, 0,
				`Verdana`,
			)
			
			old_font := SelectObject(hdc, hfont)
			
			// Draw text
			c_text := g_text.str
			mut rect := RECT{}
			GetClientRect(hWnd, &rect)
			DrawTextA(hdc, c_text, -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER)
			
			SelectObject(hdc, old_font)
			DeleteObject(hfont)
			ReleaseDC(hWnd, hdc)
			return 0
		}
		WM_TIMER {
			if wParam == 1 {
				KillTimer(hWnd, 1)
				DestroyWindow(hWnd)
			}
			return 0
		}
		WM_DESTROY {
			g_hwnd = &void(nil)
			PostQuitMessage(0)
			return 0
		}
		else {
			return DefWindowProcA(hWnd, Msg, wParam, lParam)
		}
	}
}

// ============================================================================
// Structures
// ============================================================================

struct RECT {
	left    int
	top     int
	right   int
	bottom  int
}

struct MSG {
	hwnd    HWND
	message u32
	wParam  WPARAM
	lParam  LPARAM
	time    u32
	pt_x    int
	pt_y    int
}

// ============================================================================
// Main OSD Function
// ============================================================================

pub fn show_osd(text string, timeout_ms int) {
	g_text = text
	g_timeout_ms = timeout_ms
	
	// Get screen dimensions
	screen_width := GetSystemMetrics(SM_CXSCREEN)
	screen_height := GetSystemMetrics(SM_CYSCREEN)
	
	// OSD window size
	osd_width := screen_width * 60 / 100
	osd_height := 120
	
	// Position at bottom center
	x := (screen_width - osd_width) / 2
	y := screen_height - osd_height - 100
	
	// Register window class
	class_name := `CAXOSD`
	hinstance := GetModuleHandleA(nil)
	hbr_bg := CreateSolidBrush(COLOR_KEY)
	
	RegisterClassA(class_name, wnd_proc, hinstance, hbr_bg)
	
	// Create OSD window
	g_hwnd = CreateWindowExA(
		WS_EX_LAYERED | WS_EX_TOPMOST,
		class_name,
		`CAX OSD`,
		WS_POPUP | WS_VISIBLE,
		x, y, osd_width, osd_height,
		&void(nil),
		&void(nil),
		hinstance,
		nil,
	)
	
	if g_hwnd == &void(nil) {
		eprintln('Failed to create OSD window. Error: ${GetLastError()}')
		return
	}
	
	// Set color key transparency
	SetLayeredWindowAttributes(g_hwnd, COLOR_KEY, 0, LWA_COLORKEY)
	
	// Show window
	ShowWindow(g_hwnd, SW_SHOWNORMAL)
	UpdateWindow(g_hwnd)
	
	// Set timer
	SetTimer(g_hwnd, 1, u32(timeout_ms), nil)
	
	// Message loop
	mut msg := MSG{}
	for GetMessageA(&msg, g_hwnd, 0, 0) != 0 {
		TranslateMessage(&msg)
		DispatchMessageA(&msg)
	}
}

// ============================================================================
// Test
// ============================================================================

fn main() {
	args := os.args
	
	mut text := 'OSD Test'
	mut timeout := 2000
	
	if args.len > 1 {
		timeout = args[1].int() * 100
	}
	if args.len > 2 {
		text = args[2]
	}
	
	println('Showing OSD: "${text}" for ${timeout / 1000}s')
	show_osd(text, timeout)
	println('OSD closed')
}

import os
