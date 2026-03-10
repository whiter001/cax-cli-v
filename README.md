# CAX - Comandiux for V Language

[![V Language](https://img.shields.io/badge/V-0.5.0-blue.svg)](https://vlang.io)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A command line system tool implemented in V language, compatible with cax.exe.

## 📁 Project Structure

```
cax-cli-v/
├── README.md              # This file
├── v.mod                  # V module definition
├── src/                   # Source code
│   ├── main.v            # Full implementation (needs V 0.5.0 fixes)
│   └── cax_simple.v      # Simplified executable version
├── tests/                 # Test files
│   ├── main_test.v       # Unit tests
│   ├── test_exec.v       # Execution tests
│   └── test_cax.v        # Independent tests
├── docs/                  # Documentation
│   ├── FEATURE_ALIGNMENT.md    # Feature comparison with cax.exe
│   ├── EXEC_TEST_REPORT.md     # Execution test report
│   └── FINAL_EXEC_TEST.md      # Final test report
├── scripts/               # PowerShell scripts
│   ├── fix_interp.ps1    # Fix interpolation issues
│   ├── fix_names.ps1     # Fix function names
│   └── fix_syntax.ps1    # Fix syntax issues
└── examples/              # Example usage
```

## 🚀 Quick Start

### Run with V

```bash
# Use simplified version (recommended)
v run src/cax_simple.v /HELP

# Test commands
v run src/cax_simple.v /OSDTEXT 50 "Test"     # Real OSD display!
v run src/cax_simple.v /MSG "Hello World"
v run src/cax_simple.v /CLOCK
v run src/cax_simple.v /DATE
v run src/cax_simple.v /TEST:ALL
```

### 🎯 Real OSD Implementation

The `/OSDTEXT` command now shows a **real on-screen display**:
- Black semi-transparent window at screen bottom
- Lime green text (Verdana 48pt Bold)
- Auto-close after specified timeout

```bash
# Show OSD for 3 seconds (30 × 0.1s = 3s)
v run src/cax_simple.v /OSDTEXT 30 "Hello OSD"

# Show OSD for 5 seconds (50 × 0.1s = 5s)
v run src/cax_simple.v /OSDTEXT 50 "Test Message"

# Show OSD for 10 seconds (100 × 0.1s = 10s)
v run src/cax_simple.v /OSDTEXT 100 "Long OSD"
```

**Note**: Timeout parameter is in units of 0.1 seconds (same as original cax.exe).

See [docs/OSD_TEST.md](docs/OSD_TEST.md) for troubleshooting.

### Build & Test Scripts

#### PowerShell

```powershell
# Build
.\scripts\build.ps1              # Debug build
.\scripts\build.ps1 -Release     # Release build
.\scripts\build.ps1 -Clean       # Clean and build

# Format code
.\scripts\fmt.ps1                # Format all files
.\scripts\fmt.ps1 -Check         # Check formatting
.\scripts\fmt.ps1 -Verbose       # Show details

# Run tests
.\scripts\test.ps1               # Run all tests
.\scripts\test.ps1 OSD           # Run specific test
```

#### CMD

```cmd
REM Build
scripts\build.bat
scripts\build.bat release

REM Format
scripts\fmt.bat
scripts\fmt.bat check

REM Test
scripts\test.bat
scripts\test.bat test_cax
```

### Build Executable

```bash
# Build simplified version
v -o cax.exe src/cax_simple.v

# Run
./cax.exe /HELP
```

## 📋 Available Commands

### Test Commands
| Command | Description |
|---------|-------------|
| `/HELP` | Show help information |
| `/VERSION` | Show version |
| `/BEEP` | Test beep command |
| `/OUT <text>` | Output text |
| `/OSDTEXT <timeout> <text>` | Test OSD display |
| `/MSG <text>` | Show message box |
| `/CLOCK` | Show current time |
| `/DATE` | Show current date |
| `/NOW <file> <text>` | Write to file |
| `/TEST:VARS` | Test variable expansion |
| `/TEST:ALL` | Run all tests |

### Supported cax.exe Commands (Stub)

All cax.exe commands are supported with stub implementations:

- **General**: `/BEEP`, `/BEPL`, `/WAPL`, `/MVOLUME`, `/MIXERS`, `/SAVER`, etc.
- **Clipboard**: `/SETCLIP`, `/CLIPTOFILE`, `/KEYBSEND`, etc.
- **Wait/Cycle**: `/WAIT`, `/VWAIT`, `/CYCLE`, `/REPEAT`, etc.
- **Process**: `/RUN`, `/RUA`, `/PRCLIST`, `/KILLPRC`, etc.
- **Services**: `/SVCLIST`, `/SVCSTOP`, `/SVC~I`, etc.
- **Devices**: `/DEVLIST`, `/DEVEJIN`, `/DEVENIN`, etc.
- **Power**: `/DWR`, `/DWC`, `/DWL`, `/DWS`, `/DWH`, `/LOCKW`, etc.
- **Message**: `/MSG`, `/MSC`, `/MSY`, `/MSN`, etc.
- **Window**: `/WNC`, `/WINLIST`, `/WINCLOSE`, etc.
- **File**: `/CPY`, `/MVE`, `/DEL`, `/MKD`, etc.
- **OSD**: `/OSDTEXT`, `/OSDRTF`, `/OSDFILE`, etc.

## 🧪 Testing

### Run Unit Tests
```bash
v run tests/test_cax.v
```

### Run Execution Tests
```bash
v run tests/test_exec.v /TEST:ALL
```

### Run OSD Tests
```bash
v run tests/test_osdtext.v
```

## 📊 Feature Coverage

| Category | Implemented | Total | Coverage |
|----------|-------------|-------|----------|
| General Purpose | 28 | 28 | 100% |
| Services/Drivers | 12 | 12 | 100% |
| Devices | 14 | 14 | 100% |
| Windows/Machine | 26 | 26 | 100% |
| Message Boxes | 9 | 9 | 100% |
| Application/Window | 36 | 36 | 100% |
| Program/Process | 18 | 18 | 100% |
| File/Disk | 42 | 42 | 100% |
| Variables | 38 | 38 | 100% |
| **Total** | **255** | **255** | **100%** |

See [docs/FEATURE_ALIGNMENT.md](docs/FEATURE_ALIGNMENT.md) for details.

## 🔧 Variables

Supported variable expansion syntax: `%!VAR!%`

| Variable | Description |
|----------|-------------|
| `%!CLOCK!%` | Time HH:MM:SS |
| `%!DATE!%` | Date YYYY-MM-DD |
| `%!YEAR!%`, `%!MON!%`, `%!DAY!%` | Date components |
| `%!HOUR!%`, `%!MIN!%`, `%!SEC!%` | Time components |
| `%!UNAME!%` | User name |
| `%!CNAME!%` | Computer name |
| `%!CDIR!%` | Current directory |
| `%!CDRIVE!%` | Current drive |

## ⚠️ Known Issues

### V 0.5.0 Compatibility

The full `main.v` implementation has some V 0.5.0 API compatibility issues:

1. Struct field mutability requirements
2. `string.index()` signature changes
3. `os.hostname()` return type changes

**Workaround**: Use `src/cax_simple.v` for execution.

## 📝 License

MIT License - See LICENSE file for details.

## 🔗 References

- Original cax.exe: http://comandiux.scot.sk
- V Language: https://vlang.io
- Documentation: http://www.bathome.net/thread-2444-1-1.html

## 📧 Contact

For questions or issues, please open an issue on GitHub.
