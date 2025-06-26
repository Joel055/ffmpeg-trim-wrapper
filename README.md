# ffmpeg-trim-wrapper

A lightweight PowerShell GUI for trimming audio and video using a bundled prebuilt ffmpeg.exe
(included for convenience, no external setup required).
Adds a right-click “Trim with ffmpeg” option to the context menu for common media formats.

- Lets you overwrite the original or save the trimmed file as a copy  
- Supports: `.mp4`, `.mkv`, `.webm`, `.mp3`, `.flac`, and more

## Install

1. Clone or download the repo, or grab the latest release package.
2. Run `install.ps1` as administrator  

## Uninstall

Run `uninst.bat` (admin) from the installed folder:  
`%LOCALAPPDATA%\ffmpeg-trim-wrapper`

## Licensing

This project includes an unmodified `ffmpeg.exe` binary from [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds),  
specifically from the archive: [`ffmpeg-N-119683-ga18b2c2696-win64-lgpl.zip`](https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2025-05-24-14-00/ffmpeg-N-119683-ga18b2c2696-win64-lgpl.zip)

**SHA-256 of the included `ffmpeg.exe`:**

    659A992EFD6A0EE7F3F5EDF4A5B64992D585B301EEB0E82A37FEE705402D8514

**To verify it yourself, run:**

    Get-FileHash .\ffmpeg.exe -Algorithm SHA256

**Licenses:**

- `ffmpeg.exe` is licensed under the LGPL v2.1 — see [`COPYING.LGPLv2.1`](COPYING.LGPLv2.1)  
- All other scripts are licensed under the MIT License — see [`LICENSE`](LICENSE)


  
