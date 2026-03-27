@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ------------------------------------------------------------
rem Install static prjct_name library (tests OFF)
rem - Default prefix: C:\Program Files\prjct_name
rem - Default build type: Release
rem - Builds prjct_name as static via BUILD_SHARED_LIBS=OFF
rem
rem Usage:
rem   static.bat
rem   static.bat --prefix "C:\prjct_name"
rem   static.bat --relwithdebinfo
rem   static.bat --generator "Ninja"
rem   static.bat --clean
rem ------------------------------------------------------------

set "PREFIX=%CMAKE_INSTALL_PREFIX%"
if "%PREFIX%"=="" set "PREFIX=C:\Program Files\prjct_name"
set "BUILD_DIR=build\static"
set "BUILD_TYPE=Release"
set "GEN=%CMAKE_GENERATOR%"
set "CLEAN=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--prefix" (
    if "%~2"=="" (
        echo ERROR: --prefix requires a value
        exit /b 1
    )
    set "PREFIX=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--release" (
    set "BUILD_TYPE=Release"
    shift
    goto parse_args
)
if /I "%~1"=="--relwithdebinfo" (
    set "BUILD_TYPE=RelWithDebInfo"
    shift
    goto parse_args
)
if /I "%~1"=="--rel" (
    set "BUILD_TYPE=RelWithDebInfo"
    shift
    goto parse_args
)
if /I "%~1"=="--debug" (
    set "BUILD_TYPE=Debug"
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
if /I "%~1"=="--clean" (
    set "CLEAN=1"
    shift
    goto parse_args
)
if /I "%~1"=="-h" goto show_help
if /I "%~1"=="--help" goto show_help

echo ERROR: Unknown arg: %~1
exit /b 1

:show_help
echo Usage: %~nx0 [--prefix DIR] [--release^|--relwithdebinfo^|--debug] [--generator NAME] [--clean]
exit /b 0

:args_done
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%\..\..") do set "PROJ_ROOT=%%~fI"
set "SRC_DIR=%PROJ_ROOT%\prjct_name"
set "OUT_DIR=%PROJ_ROOT%\%BUILD_DIR%"

where cmake >nul 2>&1 || (
    echo ERROR: cmake not found in PATH
    exit /b 1
)

if "%GEN%"=="" (
    where ninja >nul 2>&1 && set "GEN=Ninja"
)

echo ==^> Source: %SRC_DIR%
echo ==^> Build:  %OUT_DIR% ^(%BUILD_TYPE%^)
echo ==^> Prefix: %PREFIX%
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
    cmake -S "%SRC_DIR%" -B "%OUT_DIR%" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_INSTALL_PREFIX="%PREFIX%" -DBUILD_SHARED_LIBS=OFF -DPRJCT_NAME_BUILD_TESTS=OFF -DPRJCT_NAME_BUILD_STATIC=OFF
) else (
    cmake -S "%SRC_DIR%" -B "%OUT_DIR%" -G "%GEN%" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_INSTALL_PREFIX="%PREFIX%" -DBUILD_SHARED_LIBS=OFF -DPRJCT_NAME_BUILD_TESTS=OFF -DPRJCT_NAME_BUILD_STATIC=OFF
)
if errorlevel 1 exit /b 1

cmake --build "%OUT_DIR%" --config %BUILD_TYPE%
if errorlevel 1 exit /b 1

cmake --install "%OUT_DIR%" --config %BUILD_TYPE%
if errorlevel 1 exit /b 1

echo ==^> Static install complete.
echo     Headers: %PREFIX%\include\prjct_name\*.h
echo     Library: %PREFIX%\lib\prjct_name.lib
exit /b 0

