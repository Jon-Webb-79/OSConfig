@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ------------------------------------------------------------
rem Debug builder for prjct_name tests
rem - Builds Debug with PRJCT_NAME_BUILD_TESTS=ON
rem - Produces: build\debug\bin\unit_tests.exe
rem - Runs unit_tests.exe (use --no-run to skip)
rem
rem Usage:
rem   debug.bat
rem   debug.bat --no-run
rem   debug.bat --clean
rem   debug.bat --generator "Ninja"
rem ------------------------------------------------------------

set "BUILD_DIR=build\debug"
set "BUILD_TYPE=Debug"
set "RUN_AFTER_BUILD=1"
set "GEN=%CMAKE_GENERATOR%"
set "CLEAN=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--no-run" (
    set "RUN_AFTER_BUILD=0"
    shift
    goto parse_args
)
if /I "%~1"=="--clean" (
    set "CLEAN=1"
    shift
    goto parse_args
)
if /I "%~1"=="--generator" (
    if "%~2"=="" (
        echo ERROR: --generator requires a value
        exit /b 1
    )
    set "GEN=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="-h" goto show_help
if /I "%~1"=="--help" goto show_help

echo ERROR: Unknown arg: %~1
exit /b 1

:show_help
echo Usage: %~nx0 [--no-run] [--clean] [--generator NAME]
exit /b 0

:args_done
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%\..\..") do set "PROJ_ROOT=%%~fI"
set "SRC_DIR=%PROJ_ROOT%\prjct_name"
set "OUT_DIR=%PROJ_ROOT%\%BUILD_DIR%"
set "BIN_DIR=%OUT_DIR%\bin"
set "UNIT_EXE=%BIN_DIR%\unit_tests.exe"

where cmake >nul 2>&1 || (
    echo ERROR: cmake not found in PATH
    exit /b 1
)

if "%GEN%"=="" (
    where ninja >nul 2>&1 && set "GEN=Ninja"
)

echo ==^> Source: %SRC_DIR%
echo ==^> Build:  %OUT_DIR% ^(%BUILD_TYPE%^)
if "%GEN%"=="" (
    echo ==^> Gen:    ^<auto^>
) else (
    echo ==^> Gen:    %GEN%
)

if "%CLEAN%"=="1" (
    rmdir /s /q "%OUT_DIR%" 2>nul
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

if "%GEN%"=="" (
    cmake -S "%SRC_DIR%" -B "%OUT_DIR%" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DBUILD_SHARED_LIBS=ON -DPRJCT_NAME_BUILD_TESTS=ON
) else (
    cmake -S "%SRC_DIR%" -B "%OUT_DIR%" -G "%GEN%" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DBUILD_SHARED_LIBS=ON -DPRJCT_NAME_BUILD_TESTS=ON
)
if errorlevel 1 exit /b 1

cmake --build "%OUT_DIR%" --config %BUILD_TYPE% --target unit_tests
if errorlevel 1 exit /b 1

if exist "%UNIT_EXE%" (
    echo ==^> Built: %UNIT_EXE%
) else (
    echo ERROR: unit_tests executable not found: %UNIT_EXE%
    exit /b 2
)

if "%RUN_AFTER_BUILD%"=="1" (
    echo ==^> Running unit_tests
    "%UNIT_EXE%"
    if errorlevel 1 exit /b 1
)

echo ==^> Done. You can run later via: %UNIT_EXE%
exit /b 0

