// CAX - OSD (On Screen Display) Implementation
// Windows GDI+ based OSD display

module main

#flag windows -lgdi32 -luser32 -lgdiplus

#include <windows.h>
#include <gdiplus.h>

// ============================================================================
// Windows API Types
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
type GpGraphics = &void
type GpSolidFill = &void
type GpFont = &void
type GpStringFormat = &void
type GpStatus = int

// ============================================================================
// Constants
// ============================================================================

const (
	// Window styles
	WS_POPUP        = 0x80000000
	WS_VISIBLE      = 0x10000000
	WS_EX_LAYERED   = 0x00080000
	WS_EX_TOPMOST   = 0x00000008
	WS_EX_TRANSPARENT = 0x00000020
	
	// Show window commands
	SW_SHOWNORMAL   = 1
	SW_HIDE         = 0
	
	// Messages
	WM_DESTROY      = 0x0002
	WM_PAINT        = 0x000F
	WM_TIMER        = 0x0113
	
	// Colors
	COLOR_BLACK     = 0x00000000
	COLOR_LIME      = 0x00FF0000  // GDI uses BGR format
	COLOR_WHITE     = 0x00FFFFFF
	
	// GDI+ Status
	Ok              = 0
	GenericError    = 1
	InvalidParameter = 2
)

// ============================================================================
// Windows API Functions
// ============================================================================

// User32.dll
fn CreateWindowExW(dwExStyle u32, lpClassName LPCWSTR, lpWindowName LPCWSTR, 
    dwStyle u32, X int, Y int, nWidth int, nHeight int, hWndParent HWND, 
    hMenu HWND, hInstance HWND, lpParam LPVOID) HWND {
	unsafe {
		return &CreateWindowExW(dwExStyle, lpClassName, lpWindowName, 
            dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)
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

fn DefWindowProcW(hWnd HWND, Msg u32, wParam usize, lParam isize) isize {
	unsafe {
		return DefWindowProcW(hWnd, Msg, wParam, lParam)
	}
}

fn RegisterClassExW(lpwcx &void) u16 {
	unsafe {
		return RegisterClassExW(lpwcx)
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

fn SetTimer(hWnd HWND, nIDEvent usize, uElapse u32, lpTimerFunc &void) usize {
	unsafe {
		return SetTimer(hWnd, nIDEvent, uElapse, lpTimerFunc)
	}
}

fn KillTimer(hWnd HWND, nIDEvent usize) BOOL {
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

fn MultiByteToWideChar(CodePage u32, dwFlags u32, lpMultiByteStr &u8, 
    cbMultiByte int, lpWideCharStr &u16, cchWideChar int) int {
	unsafe {
		return MultiByteToWideChar(CodePage, dwFlags, lpMultiByteStr, 
            cbMultiByte, lpWideCharStr, cchWideChar)
	}
}

// GDI32.dll
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

fn CreateFontW(nHeight int, nWidth int, nEscapement int, nOrientation int, 
    fnWeight int, fdwItalic u32, fdwUnderline u32, fdwStrikeOut u32, 
    fdwCharSet u32, fdwOutputPrecision u32, fdwClipPrecision u32, 
    fdwQuality u32, fdwPitchAndFamily u32, lpszFace LPCWSTR) HFONT {
	unsafe {
		return CreateFontW(nHeight, nWidth, nEscapement, nOrientation, 
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

fn TextOutW(hdc HDC, x int, y int, lpString LPCWSTR, c int) BOOL {
	unsafe {
		return TextOutW(hdc, x, y, lpString, c)
	}
}

// ============================================================================
// Global Variables
// ============================================================================

mut (
	osd_hwnd       HWND = &void(nil)
	osd_text       string = ''
	osd_timeout_ms int = 0
	osd_visible    bool = false
)

// ============================================================================
// Helper Functions
// ============================================================================

fn string_to_wide(s string) []u16 {
	unsafe {
		len := MultiByteToWideChar(65001, 0, s.str, s.len, nil, 0)
		mut wide := []u16{len: len + 1, cap: len + 1}
		MultiByteToWideChar(65001, 0, s.str, s.len, &wide[0], len)
		wide[len] = 0
		return wide
	}
}

// ============================================================================
// OSD Functions
// ============================================================================

pub fn show_osd_text(text string, timeout_ms int) {
	osd_text = text
	osd_timeout_ms = timeout_ms
	
	// Get screen dimensions
	screen_width := GetSystemMetrics(0)
	screen_height := GetSystemMetrics(1)
	
	// Calculate OSD window size
	osd_width := screen_width * 80 / 100  // 80% of screen width
	osd_height := 100  // Fixed height
	
	// Position at bottom center
	x := (screen_width - osd_width) / 2
	y := screen_height - osd_height - 50
	
	// Create window class
	wnd_class := WNDCLASSEXW{}
	wnd_class.cbSize = u32(size_of(WNDCLASSEXW))
	wnd_class.style = 0x0003  // CS_HREDRAW | CS_VREDRAW
	wnd_class.lpfnWndProc = osd_wnd_proc
	wnd_class.hInstance = GetModuleHandleW(nil)
	wnd_class.hCursor = LoadCursorW(nil, &void(nil))  // IDC_ARROW
	wnd_class.hbrBackground = CreateSolidBrush(0x00000000)  // Black
	wnd_class.lpszClassName = string_to_wide('CAXOSDClass').str
	
	RegisterClassExW(&wnd_class)
	
	// Create OSD window
	osd_hwnd = CreateWindowExW(
		WS_EX_LAYERED | WS_EX_TOPMOST,  // Extended style
		string_to_wide('CAXOSDClass').str,  // Class name
		string_to_wide('CAX OSD').str,  // Window name
		WS_POPUP | WS_VISIBLE,  // Style
		x, y, osd_width, osd_height,  // Position and size
		&void(nil),  // Parent window
		&void(nil),  // Menu
		GetModuleHandleW(nil),  // Instance
		nil,  // Additional params
	)
	
	if osd_hwnd == &void(nil) {
		eprintln('Failed to create OSD window. Error: ${GetLastError()}')
		return
	}
	
	// Set transparency
	SetLayeredWindowAttributes(osd_hwnd, 0x000000, 0, 0x00000002)  // LWA_COLORKEY
	
	// Show window
	ShowWindow(osd_hwnd, SW_SHOWNORMAL)
	UpdateWindow(osd_hwnd)
	
	osd_visible = true
	
	// Set timer to auto-close
	SetTimer(osd_hwnd, 1, u32(timeout_ms), nil)
	
	// Message loop
	mut msg := MSG{}
	for GetMessageW(&msg, osd_hwnd, 0, 0) != 0 {
		TranslateMessage(&msg)
		DispatchMessageW(&msg)
	}
}

// ============================================================================
// Window Procedure
// ============================================================================

fn osd_wnd_proc(hWnd HWND, Msg u32, wParam usize, lParam isize) isize {
	match Msg {
		WM_PAINT {
			// Paint the OSD text
			hdc := GetDC(hWnd)
			
			// Set text color to lime green (BGR format for GDI)
			SetTextColor(hdc, 0x0000FF00)
			SetBkMode(hdc, 1)  // TRANSPARENT
			
			// Create font (Verdana, 48pt, Bold)
			hfont := CreateFontW(
				-64, 0, 0, 0, 700, 0, 0, 0,
				1, 0, 0, 5, 0,
				string_to_wide('Verdana').str,
			)
			
			old_font := SelectObject(hdc, hfont)
			
			// Get client rect
			mut rect := RECT{}
			GetClientRect(hWnd, &rect)
			
			// Draw text centered
			wide_text := string_to_wide(osd_text)
			DrawTextW(hdc, wide_text.str, -1, &rect, 
                0x00000001 | 0x00000004 | 0x00000010)  // DT_SINGLELINE | DT_CENTER | DT_VCENTER
			
			SelectObject(hdc, old_font)
			DeleteObject(hfont)
			
			ReleaseDC(hWnd, hdc)
			return 0
		}
		WM_TIMER {
			// Timer expired, close OSD
			if wParam == 1 {
				KillTimer(hWnd, 1)
				DestroyWindow(hWnd)
			}
			return 0
		}
		WM_DESTROY {
			osd_hwnd = &void(nil)
			osd_visible = false
			PostQuitMessage(0)
			return 0
		}
		else {
			return DefWindowProcW(hWnd, Msg, wParam, lParam)
		}
	}
}

// ============================================================================
// Windows API Type Definitions
// ============================================================================

struct WNDCLASSEXW {
	cbSize          u32
	style           u32
	lpfnWndProc     &void
	cbClsExtra      int
	cbWndExtra      int
	hInstance       HWND
	hIcon           HWND
	hCursor         HWND
	hbrBackground   HBRUSH
	lpszMenuName    LPCWSTR
	lpszClassName   LPCWSTR
	hIconSm         HWND
}

struct MSG {
	hwnd        HWND
	message     u32
	wParam      usize
	lParam      isize
	time        u32
	pt          POINT
}

struct POINT {
	x   int
	y   int
}

struct RECT {
	left    int
	top     int
	right   int
	bottom  int
}

// ============================================================================
// Additional Windows API Declarations
// ============================================================================

fn GetModuleHandleW(lpModuleName LPCWSTR) HWND {
	unsafe {
		return GetModuleHandleW(lpModuleName)
	}
}

fn LoadCursorW(hInstance HWND, lpCursorName HWND) HWND {
	unsafe {
		return LoadCursorW(hInstance, lpCursorName)
	}
}

fn GetMessageW(lpMsg &MSG, hWnd HWND, wMsgFilterMin u32, wMsgFilterMax u32) i32 {
	unsafe {
		return GetMessageW(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax)
	}
}

fn TranslateMessage(lpMsg &MSG) BOOL {
	unsafe {
		return TranslateMessage(lpMsg)
	}
}

fn DispatchMessageW(lpMsg &MSG) isize {
	unsafe {
		return DispatchMessageW(lpMsg)
	}
}

fn GetClientRect(hWnd HWND, lpRect &RECT) BOOL {
	unsafe {
		return GetClientRect(hWnd, lpRect)
	}
}

fn DrawTextW(hdc HDC, lpchText LPCWSTR, cchText int, lprc &RECT, format u32) int {
	unsafe {
		return DrawTextW(hdc, lpchText, cchText, lprc, format)
	}
}
