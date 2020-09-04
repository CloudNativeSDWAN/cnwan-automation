# Download the VLC installer
Invoke-WebRequest 'http://mirrors.osuosl.org/pub/videolan/vlc/3.0.11/win64/vlc-3.0.11-win64.exe' -OutFile 'C:\Windows\Temp\vlc-installer.exe'

# Use silent installation for VLC, choosing English as the UI language
C:\Windows\Temp\vlc-installer.exe /S /L=1033
