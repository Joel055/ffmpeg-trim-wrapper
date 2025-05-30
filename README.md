# ffmpeg-trim-wrapper

A lightweight PowerShell GUI that trims audio and video files using `ffmpeg.exe`.  
Adds a right-click “Trim with ffmpeg” option to the context menu for common media formats.

- Lets you overwrite the original or save the trimmed file as a copy  
- Supports: `.mp4`, `.mkv`, `.webm`, `.mp3`, `.flac`, and more

## Install

1. Clone/download the repo  
2. Run `install.ps1` as administrator  

## Uninstall

Run `uninst.bat` (admin) from the installed folder:  
`%LOCALAPPDATA%\ffmpeg-trim-wrappe`

## Licensing

- `ffmpeg.exe` is LGPL v2.1 — source: [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds)  
  See [`COPYING.LGPLv2.1`](COPYING.LGPLv2.1)

- All scripts in this project are MIT licensed — see [`LICENSE`](LICENSE)
