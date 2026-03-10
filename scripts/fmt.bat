@echo off
REM CAX Format Script for Windows CMD
REM Usage: fmt.bat [check]

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set SRC_DIR=%PROJECT_ROOT%\src
set TESTS_DIR=%PROJECT_ROOT%\tests

echo CAX Format Script
echo =================
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

set FORMATTED=0
set ERRORS=0

REM Format source files
echo Formatting source files...
for %%f in (%SRC_DIR%\*.v) do (
    if "%1"=="check" (
        v fmt %%f >nul 2>&1
        if errorlevel 1 (
            echo   Error: %%~nxf
            set /a ERRORS+=1
        ) else (
            echo   OK: %%~nxf
            set /a FORMATTED+=1
        )
    ) else (
        v fmt -w %%f >nul 2>&1
        if errorlevel 1 (
            echo   Error: %%~nxf
            set /a ERRORS+=1
        ) else (
            echo   Formatted: %%~nxf
            set /a FORMATTED+=1
        )
    )
)

echo.

REM Format test files
echo Formatting test files...
for %%f in (%TESTS_DIR%\*.v) do (
    if "%1"=="check" (
        v fmt %%f >nul 2>&1
        if errorlevel 1 (
            echo   Error: %%~nxf
            set /a ERRORS+=1
        ) else (
            echo   OK: %%~nxf
            set /a FORMATTED+=1
        )
    ) else (
        v fmt -w %%f >nul 2>&1
        if errorlevel 1 (
            echo   Error: %%~nxf
            set /a ERRORS+=1
        ) else (
            echo   Formatted: %%~nxf
            set /a FORMATTED+=1
        )
    )
)

echo.
echo Summary:
echo   Formatted: %FORMATTED% files
if %ERRORS% gtr 0 (
    echo   Errors: %ERRORS% files
    exit /b 1
) else (
    echo   Errors: 0
    echo.
    echo All files formatted successfully!
)
