@echo off
REM CAX Build Script for Windows CMD
REM Usage: build.bat [output] [release]

setlocal enabledelayedexpansion

set OUTPUT=%1
if "%OUTPUT%"=="" set OUTPUT=cax.exe

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set SRC_DIR=%PROJECT_ROOT%\src

echo CAX Build Script
echo ================
echo.

REM Check V installation
echo Checking V installation...
v version >nul 2>&1
if errorlevel 1 (
    echo Error: V language is not installed or not in PATH
    echo Download from: https://vlang.io
    exit /b 1
)

for /f "tokens=*" %%v in ('v version 2^>^&1') do set V_VERSION=%%v
echo   V version: %V_VERSION%
echo.

REM Build
echo Building CAX...
if "%2"=="release" (
    echo   Mode: Release (optimized)
    v -prod -o %PROJECT_ROOT%\%OUTPUT% %SRC_DIR%\cax_simple.v
) else (
    echo   Mode: Debug
    v -o %PROJECT_ROOT%\%OUTPUT% %SRC_DIR%\cax_simple.v
)

if errorlevel 1 (
    echo.
    echo Build failed!
    exit /b 1
)

echo.
echo Build successful!
echo   Output: %PROJECT_ROOT%\%OUTPUT%
echo.
echo Run with: %OUTPUT% /HELP
