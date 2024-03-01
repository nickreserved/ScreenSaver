@echo off
nasm -iWin32inc\ -fobj ScreenSaver.asm
alink -oPE ScreenSaver.obj Configure.res
del *.obj