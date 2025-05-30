@echo off
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    echo Uninstallation script requires administrative rights to run.
    pause
    exit /b
)

for %%S in (
    .mp4
    .mkv
    .webm
    .avi
    .mov
    .wmv
    .flv
    .m4v
    .mp3
    .wav
    .flac
    .aac
    .ogg
    .opus
) do reg delete "HKEY_LOCAL_MACHINE\Software\Classes\SystemFileAssociations\%%S\shell\TrimWithFfmpeg" /f

:: Create a detached tempscript so explorer can be killed without the cmd session imploding
(
    echo @echo off
    echo timeout /t 1 ^>nul
    echo taskkill /f /im explorer.exe ^>nul 2^>^&1
    echo start explorer.exe
    echo cd /d %%TEMP%%
    echo rmdir /S /Q "%%LOCALAPPDATA%%\ffmpeg-trim-wrapper" ^>nul 2^>^&1
    echo echo Uninstallation complete.
    echo timeout /t 3 /nobreak ^> nul
    echo del "%%~f0"
) > "%TEMP%\e.bat"

start "" cmd /c "%TEMP%\e.bat"
exit