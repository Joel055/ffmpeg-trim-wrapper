# Elevation check: self-invoke via UAC if not already running as admin
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity

if (-Not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs

    exit 0
}

$dir = "$Env:LOCALAPPDATA\ffmpeg-trim-wrapper"
$cmd = 'powershell.exe -Command "Start-Process -WindowStyle Hidden powershell -ArgumentList ''-NoProfile -ExecutionPolicy Bypass -File \"' + "$dir\trim-ui.ps1" + '\" \"%1%\"''"'
$icon = "%SystemRoot%\System32\shell32.dll,041" 
$mediaExts = @(
    ".mp4",
    ".mkv",
    ".webm",
    ".avi",
    ".mov",
    ".wmv",
    ".flv",
    ".m4v",
    ".mp3",
    ".wav",
    ".flac",
    ".aac",
    ".ogg",
    ".opus"
)

# Create an install-directory
New-Item -ItemType Directory -Path $dir -Force | Out-Null
Copy-Item -Path $PSScriptRoot\app\* -Destination $dir -Force

# Create context-menu keys for each extension
foreach ($ext in $mediaExts) {
    $ctxPath = "HKLM:\Software\Classes\SystemFileAssociations\$($ext)\shell\TrimWithFfmpeg"
    
    New-Item -Path $ctxPath -Force | Out-Null
    Set-Item -Path $ctxPath -Value "Trim with ffmpeg"

    New-Item -Path "$ctxPath\command" -Force | Out-Null
    Set-Item -Path "$ctxPath\command" -Value $cmd 

    New-ItemProperty -Path $ctxPath -Name "Icon" -Value $icon -PropertyType String | Out-Null
}

Write-Host "`n`Installation complete."
taskkill /f /im explorer.exe | Out-Null
Start-Process explorer
Start-Sleep -Seconds 3
