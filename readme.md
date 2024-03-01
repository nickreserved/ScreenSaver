# Basic Information
A very simple Windows screen saver, written in pure x86 Assembly when I jump from DOS to Windows and tried to wrote Assembly on Windows.

Strings in program, are in Greek language.

Written for NASM Assembler and ALINK Linker on April 2002.

1. Rename file ScreenSaver.exe to ScreenSaver.scr
2. Move it to folder C:\Windows\System (Win9x/WinME) or c:\winnt\system32 (WinNT/Win2000)
3. From Control Panel -> Display Settings -> Screen Saver choose it
4. Enjoy

# Command Line Parameters (as all screensavers)

|Parameter|Description             |
|---------|------------------------|
|/C       |Setup                   |
|/A       |Setup password (ignored)|

Screen saver setup creates registry key
HKEY_LOCAL_MACHINE\Software\Gessos Screen Saver\
where the preferred dimensions of moving rectange stored.