%include "windows.inc"
%include "Resource.h"


[section code public use32 class=CODE]

..start:
	%include "Argument.asm"

View:
	%include "View.asm"

Setup:
	%include "Setup.asm"

Pass:	STDCALL MessageBoxA,[hWnd],NoPass,NoPassCaption,MB_ICONINFORMATION

Exit:	STDCALL ExitProcess,0


; <<-- � ����� ���� ���������� ��� �������� ������� ��� ������ -->>
Resolution:
	STDCALL GetSystemMetrics,SM_CXSCREEN
	mov [DeskX],eax
	STDCALL GetSystemMetrics,SM_CYSCREEN
	mov [DeskY],eax
	ret


[section data public use32 class=DATA]

NoPass		db '���� � ��������� ������ ��������� ��� ��� ����� �����.',13,10,'��� ������������� ������� ������ ��� �� ������ �������... :-)',0
NoPassCaption	db '� ��� ������...',0
RegKey		db 'software\Gessos Screen Saver',0
RegSize		dd 8
SymStr		db '%lu',0

wcl:	istruc WNDCLASS
	at WNDCLASS.lpfnWndProc,	dd WinProc
	at WNDCLASS.lpszClassName,	dd .name
	iend
.name:	db 'WinCls',0



[section bss use32]


; !!!-- �������!!! ���� ���������� ���������� �� (X,Y),(W,H) �� ��� �������� � ����� ����!!! ---!!!

DeskWnd		resd 1		; hWnd ��� Desktop
hWnd		resd 1		; hWnd ��� ���������
DeskDC		resd 1		; hDC ��� Desktop
hDC		resd 1		; hDC ��� ���������
VirtDC		resd 1		; hDC ��� Virtual ���������
Bmp		resd 1		; hBitmap
KeyHandle	resd 1		; ��������� �������� �������
IsMoving	resb 1		; ������ ���� �������� �� ���������
msg		resb MSG_size	; ������

DeskX		resd 1		; XxY ��� ������
DeskY		resd 1
CurBlackX	resd 1		; X & Y ��� ��������� ����������
CurBlackY	resd 1
MovingX		resd 1		; X & Y ��� �������������� ����������
MovingY		resd 1
NextX		resd 1		; X & Y ��� �������� ����������
NextY		resd 1


RegVal:
RegMW	resd 1		; XxY ��� ����������
RegMH	resd 1

AllBSS	resb 10