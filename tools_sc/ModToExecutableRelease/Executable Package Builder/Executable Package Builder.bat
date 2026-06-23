@echo off
cd /d "%~dp0"

set /a count=0

:: check for dependencies
if not exist "ResourceHacker.exe" (
    echo ResourceHacker.exe is missing.
    call :onError
)
if not exist "7zSD.sfx" (
    echo 7zSD.sfx is missing.
    call :onError
)
if not exist "7zr.exe" (
    echo 7zr.exe is missing.
    call :onError
)
if not exist "default.ico" (
    echo default.ico is missing.
    call :onError
)

:: credits
title Executable Package Builder
color 0F
echo Executable Package Builder (v2.0.2)
echo Created by FireRainV! :3
echo.

setlocal EnableDelayedExpansion

:: file name
set "file=Test"
set /p "file=File Name: "

:: version
set "version=1.0.0"
set /p "version=File Version (example: 1.0.0): "
set "version_true=%version%"

:: loop to append .0 until the version contains 4 parts
:append_version
for /f "tokens=4 delims=." %%a in ("%version%") do goto done_appending
set "version=%version%.0"
goto append_version
:done_appending

set "version_commas=%version:.=,%"

choice /n /m "Run as administrator? (Y/N): "
if not errorlevel 2 (set "admin=true") else (set "admin=false")

:: credits
set "credits=Unknown"
set /p "credits=Author: "

:: icon
set "icon=%~dp0\default.ico"
set /p "icon=Icon Path (.ico): "

if "%icon:~1,1%" neq ":" (
    set "icon=%~dp0%icon%"
)

if not exist "%icon%" (
    echo Icon file not found.
    call :onError
)

if /I not "!icon:~-4!"==".ico" (
    echo File must be a .ico file.
    call :onError
)

:: output folder
set "output=%userprofile%\Desktop"
set /p "output=Output Folder Path (Default to Desktop): "

if not exist "%output%" (
    echo.
    echo Folder not found.
    call :onError
)

:: folder
set /p "folder=Executable Folder Path (Required): "

if not defined folder (
    echo.
    echo Folder path cannot be empty.
    call :onError
)

if "%folder:~1,1%" neq ":" (
    set "folder=%~dp0%folder%"
)

if not exist "%folder%" (
    echo.
    echo Folder not found.
    call :onError
)

:: list all .exe/.bat files
echo.
set /a exe_count=0
for %%F in ("%folder%\*.exe", "%folder%\*.bat") do (
    set /a exe_count+=1
    set "exe!exe_count!=%%~nxF"
    echo !exe_count!. %%~nxF
)

if %exe_count%==0 (
    echo No executable files found.
    call :onError
)
echo.

:: select .exe/.bat index
set /p "index=Select executable number to launch: "
set "launch=!exe%index%!"
if not defined launch (
    echo.
    echo Invalid selection.
    call :onError
)
echo.

:: command-line parameters
set /p "args=Launch Parameters: "

setlocal DisableDelayedExpansion
(
    echo ;!@Install@!UTF-8!
    echo Progress="no"
    echo RunProgram="%launch% %args%"
    echo ;!@InstallEnd@!
)>"%tmp%\7zip_config.txt"

echo.
echo Building package...
"%~dp0\7zr.exe" a "%tmp%\%file%.7z" "%folder%\*" -mx=0 >nul 2>&1
copy /Y /B 7zSD.sfx + "%tmp%\7zip_config.txt" + "%tmp%\%file%.7z" "%tmp%\%file%.exe" >nul 2>&1
echo.

(
    echo LANGUAGE LANG_NEUTRAL, SUBLANG_NEUTRAL
    echo.
    echo.
    echo 1 VERSIONINFO
    echo FILEVERSION %version_commas%
    echo PRODUCTVERSION %version_commas%
    echo FILEOS 0x40004
    echo FILETYPE 0x1
    echo {
    echo BLOCK "StringFileInfo"
    echo {
    echo     BLOCK "040904B0"
    echo     {
    echo         VALUE "CompanyName", "%credits%"
    echo         VALUE "FileDescription", "%file% v%version_true% by %credits%"
    echo         VALUE "FileVersion", "%version%"
    echo         VALUE "InternalName", "%file%.exe"
    echo         VALUE "LegalCopyright", "%credits%"
    echo         VALUE "OriginalFilename", "%file%.exe"
    echo         VALUE "ProductName", "%file%"
    echo         VALUE "ProductVersion", "%version%"
    echo     }
    echo }
    echo.
    echo BLOCK "VarFileInfo"
    echo {
    echo     VALUE "Translation", 0x0409, 0x04B0  
    echo }
    echo }
)>"%tmp%\version_info.rc"

(
    echo ^<?xml version="1.0" encoding="UTF-8" standalone="yes"?^>
    echo ^<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0"^>
    echo   ^<trustInfo xmlns="urn:schemas-microsoft-com:asm.v3"^>
    echo     ^<security^>
    echo       ^<requestedPrivileges^>
    if %admin%==false (
        echo         ^<requestedExecutionLevel level="asInvoker" uiAccess="false"/^>
    ) else (
        echo         ^<requestedExecutionLevel level="requireAdministrator" uiAccess="false"/^>
    )
    echo       ^</requestedPrivileges^>
    echo     ^</security^>
    echo   ^</trustInfo^>
    echo ^</assembly^>
)>"%tmp%\admin.manifest"


:: change icon and description
ResourceHacker.exe -open "%tmp%\version_info.rc" -save "%tmp%\version_info.res" -log "NUL" -action compile
(
    echo [FILENAMES]
    echo Open="%tmp%\%file%.exe"
    echo Save="%output%\%file%.exe"
    echo Log=NUL
    echo.
    echo [COMMANDS]
    echo -addoverwrite "%icon%", ICONGROUP,1,
    echo -addoverwrite "%tmp%\version_info.res",VERSIONINFO, ,
    echo -addoverwrite "%tmp%\admin.manifest" MANIFEST,1,
)>"%tmp%\script.txt"

ResourceHacker.exe -script "%tmp%\script.txt"

:: cleanup
del "%tmp%\%file%.exe" >nul 2>&1
del "%tmp%\script.txt" >nul 2>&1
del "%tmp%\version_info.rc" >nul 2>&1
del "%tmp%\version_info.res" >nul 2>&1
del "%tmp%\admin.manifest" >nul 2>&1
del "%tmp%\7zip_config.txt" >nul 2>&1
del "%tmp%\%file%.7z" >nul 2>&1
del "ResourceHacker.ini" >nul 2>&1
del "ResourceHacker.log" >nul 2>&1

if not exist "%output%\%file%.exe" (
    echo Executable package building failed.
    call :onError
)

echo Done!
echo Your executable is located at: "%output%\%file%.exe"
color 0A
echo.
pause
exit /b

:onError
color 0C
echo.
pause
exit