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


; <<-- Η κλήση αυτή επιστρέφει την τρέχουσα ανάλυση της οθόνης -->>
Resolution:
	STDCALL GetSystemMetrics,SM_CXSCREEN
	mov [DeskX],eax
	STDCALL GetSystemMetrics,SM_CYSCREEN
	mov [DeskY],eax
	ret


[section data public use32 class=DATA]

NoPass		db 'Αυτή η προφύλαξη οθόνης φτιάχτηκε από τον Παύλο Γκέσο.',13,10,'Δεν υποστηρίζεται κωδικός επειδή δεν το έκρινε χρήσιμο... :-)',0
NoPassCaption	db 'Ε ναί λοιπόν...',0
RegKey		db 'software\Gessos Screen Saver',0
RegSize		dd 8
SymStr		db '%lu',0

wcl:	istruc WNDCLASS
	at WNDCLASS.lpfnWndProc,	dd WinProc
	at WNDCLASS.lpszClassName,	dd .name
	iend
.name:	db 'WinCls',0



[section bss use32]


; !!!-- ΠΡΟΣΟΧΗ!!! Όσες μεταβλητές τελειώνουν σε (X,Y),(W,H) να μην αλλαχτεί η σειρά τους!!! ---!!!

DeskWnd		resd 1		; hWnd του Desktop
hWnd		resd 1		; hWnd του παραθύρου
DeskDC		resd 1		; hDC του Desktop
hDC		resd 1		; hDC του παραθύρου
VirtDC		resd 1		; hDC του Virtual παραθύρου
Bmp		resd 1		; hBitmap
KeyHandle	resd 1		; Χειριστής κλειδιού μητρώου
IsMoving	resb 1		; Ενεργό όταν κινείται το τετράγωνο
msg		resb MSG_size	; μήνυμα

DeskX		resd 1		; XxY της οθόνης
DeskY		resd 1
CurBlackX	resd 1		; X & Y του τρέχοντος τετραγώνου
CurBlackY	resd 1
MovingX		resd 1		; X & Y του μετακινούμενου τετραγώνου
MovingY		resd 1
NextX		resd 1		; X & Y του επομένου τετραγώνου
NextY		resd 1


RegVal:
RegMW	resd 1		; XxY του τετραγώνου
RegMH	resd 1

AllBSS	resb 10