# ffmpeg-trim-wrapper

A lightweight PowerShell GUI for trimming audio and video using a bundled prebuilt ffmpeg.exe
(included for convenience, no external setup required).
Adds a right-click “Trim with ffmpeg” option to the context menu for common media formats.

- Lets you overwrite the original or save the trimmed file as a copy  
- Supports: `.mp4`, `.mkv`, `.webm`, `.mp3`, `.flac`, and more

## Install

1. Clone or download the repo, or grab the latest release package.
2. Run `install.bat`

## Uninstall

Run `uninst.bat` (admin) from the installation folder:  
`%LOCALAPPDATA%\ffmpeg-trim-wrapper`

## Licensing

This project utilizes an already installed ffmpeg instance, or downloads it from winget.

**Licenses:**

- ffmpeg is licensed under the LGPL v2.1 — see [`COPYING.LGPLv2.1`](COPYING.LGPLv2.1)  
- All other scripts are licensed under the MIT License — see [`LICENSE`](LICENSE)
