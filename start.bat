@echo off
setlocal EnableExtensions EnableDelayedExpansion
title HE THONG QUAN LY FACEBOOK TOOL - ARCHITECTURE V2

:: ========================================================
:: CAU HINH
:: ========================================================

set "BASE_PORT=9222"
set "ROOT=%~dp0"
set "PROFILE_ROOT=%~dp0profiles"
set "VENV=%~dp0venv"
set "BROWSER_PATH=%~dp0Ungoogled Chromium\app\chrome.exe"

:: ========================================================
:: MENU
:: ========================================================

:MENU
cls

echo ========================================================
echo        HE THONG QUAN LY FACEBOOK TOOL - PROFILES
echo ========================================================
echo.

if not exist "%PROFILE_ROOT%" (
    mkdir "%PROFILE_ROOT%"
)

set "COUNT=0"

echo Danh sach Profile hien co:
echo.

for /f "delims=" %%I in ('dir /b /ad "%PROFILE_ROOT%" 2^>nul') do (
    set /a COUNT+=1
    set "PROF_!COUNT!=%%I"
    set /a PROF_PORT_!COUNT!=BASE_PORT + COUNT - 1

    echo   [!COUNT!] %%I  ----^> [CDP Port: !PROF_PORT_!COUNT!!]
)

if !COUNT! EQU 0 (
    echo   (Chua co Profile nao duoc tao)
)

echo.

set /a NEW_OPT=COUNT+1
set /a SERVER_OPT=COUNT+2

echo   [!NEW_OPT!] Tao Profile moi
echo   [!SERVER_OPT!] Khoi dong FastAPI Server ^(:8000^)
echo   [0] Thoat
echo.

echo ========================================================

set "CHOICE="
set /p "CHOICE=Nhap lua chon cua ban: "

if not defined CHOICE goto MENU

if "!CHOICE!"=="0" (
    exit /b 0
)

if "!CHOICE!"=="!NEW_OPT!" (
    goto CREATE_PROFILE
)

if "!CHOICE!"=="!SERVER_OPT!" (
    goto LAUNCH_SERVER
)

:: ========================================================
:: TIM PROFILE DUOC CHON
:: ========================================================

set "SELECTED_PROFILE="
set "SELECTED_PORT="

for /l %%G in (1,1,!COUNT!) do (
    if "!CHOICE!"=="%%G" (
        set "SELECTED_PROFILE=!PROF_%%G!"
        set "SELECTED_PORT=!PROF_PORT_%%G!"
    )
)

if defined SELECTED_PROFILE (
    goto LAUNCH_BROWSER
)

echo.
echo [LOI] Lua chon khong hop le!
timeout /t 2 /nobreak >nul
goto MENU


:: ========================================================
:: TAO PROFILE
:: ========================================================

:CREATE_PROFILE

cls

echo ========================================================
echo                   TAO PROFILE MOI
echo ========================================================
echo.

set "NEW_NAME="

set /p "NEW_NAME=Nhap ten Profile moi (VD: DatVSA2): "

if not defined NEW_NAME (
    goto MENU
)

:: Kiem tra trung ten
if exist "%PROFILE_ROOT%\!NEW_NAME!\" (
    echo.
    echo [LOI] Profile "!NEW_NAME!" da ton tai!
    echo Vui long chon ten khac.
    timeout /t 3 /nobreak >nul
    goto CREATE_PROFILE
)

mkdir "%PROFILE_ROOT%\!NEW_NAME!"

if !errorlevel! NEQ 0 (
    echo.
    echo [LOI] Khong the tao Profile "!NEW_NAME!".
    echo Duong dan:
    echo "%PROFILE_ROOT%\!NEW_NAME!"
    echo.
    pause
    goto MENU
)

echo.
echo [OK] Da tao Profile: !NEW_NAME!
echo.

timeout /t 2 /nobreak >nul
goto MENU

:: ========================================================
:: KHOI DONG CHROMIUM
:: ========================================================

:LAUNCH_BROWSER

cls

set "PROFILE_DIR=%PROFILE_ROOT%\!SELECTED_PROFILE!"

echo ========================================================
echo  MO UNGOOGLED CHROMIUM
echo ========================================================
echo.
echo  Profile : !SELECTED_PROFILE!
echo  CDP Port: !SELECTED_PORT!
echo.

if not exist "!BROWSER_PATH!" (
    echo [LOI] Khong tim thay Chromium:
    echo.
    echo !BROWSER_PATH!
    echo.
    pause
    goto MENU
)

:: Kiem tra profile directory
if not exist "!PROFILE_DIR!" (
    mkdir "!PROFILE_DIR!"

    if !errorlevel! NEQ 0 (
        echo [LOI] Khong the tao Profile Directory!
        pause
        goto MENU
    )
)

echo [INFO] Dang khoi dong Chromium...

start "" "!BROWSER_PATH!" ^
    --remote-debugging-port=!SELECTED_PORT! ^
    --user-data-dir="!PROFILE_DIR!" ^
    --profile-directory="Default" ^
    --disable-features=ProfilePicker ^
    --no-first-run ^
    --no-default-browser-check ^
    "https://www.facebook.com"

if !errorlevel! NEQ 0 (
    echo.
    echo [LOI] Khong the khoi dong Chromium!
    pause
    goto MENU
)

echo.
echo [OK] Chromium da duoc khoi dong.
echo [INFO] CDP Port: !SELECTED_PORT!

timeout /t 2 /nobreak >nul
goto MENU


:: ========================================================
:: KHOI DONG FASTAPI
:: ========================================================

:LAUNCH_SERVER

cls

echo ========================================================
echo               KHOI DONG FASTAPI SERVER
echo ========================================================
echo.

:: --------------------------------------------------------
:: Kiem tra Python
:: --------------------------------------------------------

set "PYTHON_CMD="

py --version >nul 2>&1

if !errorlevel! EQU 0 (
    set "PYTHON_CMD=py"
)

if not defined PYTHON_CMD (
    python --version >nul 2>&1

    if !errorlevel! EQU 0 (
        set "PYTHON_CMD=python"
    )
)

if not defined PYTHON_CMD (
    echo [LOI CRITICAL]
    echo.
    echo Khong tim thay Python hoac Python Launcher ^(py^)!
    echo.
    echo Hay cai Python va chon:
    echo.
    echo     Add Python to PATH
    echo.
    pause
    goto MENU
)

echo [OK] Python: !PYTHON_CMD!

:: --------------------------------------------------------
:: Tao VENV
:: --------------------------------------------------------

if not exist "%VENV%\Scripts\python.exe" (

    echo.
    echo [INFO] Dang tao Python Virtual Environment...

    !PYTHON_CMD! -m venv "%VENV%"

    if !errorlevel! NEQ 0 (
        echo.
        echo [LOI] Tao venv that bai!
        echo.
        pause
        goto MENU
    )

    echo [OK] Tao venv thanh cong.
)

:: --------------------------------------------------------
:: Kiem tra requirements
:: --------------------------------------------------------

if not exist "%ROOT%requirements.txt" (
    echo.
    echo [LOI] Khong tim thay:
    echo.
    echo %ROOT%requirements.txt
    echo.
    pause
    goto MENU
)

set "NEED_INSTALL=0"

if not exist "%VENV%\requirements.installed" (

    set "NEED_INSTALL=1"

) else (

    fc /b "%ROOT%requirements.txt" "%VENV%\requirements.installed" >nul 2>&1

    if !errorlevel! NEQ 0 (
        set "NEED_INSTALL=1"
    )
)

:: --------------------------------------------------------
:: Cai thu vien
:: --------------------------------------------------------

if "!NEED_INSTALL!"=="1" (

    echo.
    echo [INFO] Dang cai/cap nhat dependencies...
    echo.

    "%VENV%\Scripts\python.exe" -m pip install -r "%ROOT%requirements.txt"

    if !errorlevel! NEQ 0 (
        echo.
        echo [LOI] pip install that bai!
        echo.
        echo requirements.installed KHONG duoc cap nhat.
        echo Lan sau script se tu dong thu lai.
        echo.
        pause
        goto MENU
    )

    copy /y "%ROOT%requirements.txt" "%VENV%\requirements.installed" >nul

    echo.
    echo [OK] Dependencies da dong bo.

) else (

    echo [OK] Dependencies da duoc dong bo.
)

:: --------------------------------------------------------
:: Kiem tra main.py
:: --------------------------------------------------------

if not exist "%ROOT%main.py" (
    echo.
    echo [LOI] Khong tim thay main.py!
    echo.
    pause
    goto MENU
)

:: --------------------------------------------------------
:: Khoi dong FastAPI cua so rieng
:: --------------------------------------------------------

echo.
echo [INFO] Dang khoi dong FastAPI Server...
echo.
echo URL:
echo     http://127.0.0.1:8000
echo.

start "FastAPI Server" cmd /k "cd /d "%ROOT%" && call "%VENV%\Scripts\activate.bat" && python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000"

timeout /t 2 /nobreak >nul

echo.
echo [OK] Lenh khoi dong FastAPI da duoc gui.
echo.

goto MENU