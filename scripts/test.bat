@echo off
REM CAX Test Runner Script for Windows CMD
REM Usage: test.bat [testname]

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set TESTS_DIR=%PROJECT_ROOT%\tests

echo CAX Test Runner
echo ===============
echo.

REM Check V installation
echo Checking V installation...
v version >nul 2>&1
if errorlevel 1 (
    echo Error: V language is not installed or not in PATH
    exit /b 1
)

for /f "tokens=*" %%v in ('v version 2^>^&1') do set V_VERSION=%%v
echo   V version: %V_VERSION%
echo.

set PASSED=0
set FAILED=0

if not "%1"=="" (
    REM Run specific test
    echo Running: %1
    echo.
    v run %TESTS_DIR%\%1.v
    if errorlevel 1 (
        set /a FAILED+=1
    ) else (
        set /a PASSED+=1
    )
) else (
    REM Run all tests
    echo Running all tests...
    echo.
    
    for %%t in (test_cax test_osdtext test_exec) do (
        echo [%%t]
        v run %TESTS_DIR%\%%t.v
        if errorlevel 1 (
            echo   FAIL
            set /a FAILED+=1
        ) else (
            echo   PASS
            set /a PASSED+=1
        )
        echo.
    )
)

echo ===============
echo Test Summary:
echo   Passed: %PASSED%
echo   Failed: %FAILED%
echo.

if %FAILED% gtr 0 (
    echo Some tests failed!
    exit /b 1
) else (
    echo All tests passed!
)
