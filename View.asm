	; <<-- Register και Create παραθύρου. Ανάκτηση ανάλυσης οθόνης. Δημιουργία Virtual παραθύρου και αντιγραφή του Desktop σ' αυτό. -->>

	STDCALL LoadCursorA,0,IDC_ARROW
	test eax,eax
	je near Exit
	mov [wcl+WNDCLASS.hCursor],eax
	STDCALL RegisterClassA, wcl
	test eax,eax
	je near Exit

	STDCALL CreateWindowExA,WS_EX_TOPMOST|WS_EX_TOOLWINDOW,eax,0,WS_POPUP,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,0,0,0,0
	test eax,eax
	je near Exit
	mov [hWnd],eax

	call Resolution
	STDCALL GetDC,[hWnd]
	mov [hDC],eax
	STDCALL CreateCompatibleDC,eax
	mov [VirtDC],eax
	STDCALL GetDesktopWindow
	mov [DeskWnd],eax
	STDCALL GetDC,eax
	mov [DeskDC],eax
	STDCALL CreateCompatibleBitmap,[hDC],[DeskX],[DeskY]
	mov [Bmp],eax
	STDCALL SelectObject,[VirtDC],eax
	STDCALL BitBlt,[VirtDC],0,0,[DeskX],[DeskY],[DeskDC],0,0,SRCCOPY
	STDCALL ReleaseDC,[DeskWnd],[DeskDC]
	STDCALL ReleaseDC,[hWnd],[hDC]


	; <<-- Έλεγχος στη Registry για να βρεθεί αν η ανάλυση στην οποία έγινε το Setup είναι ίδια με την τρέχουσα. Στη συνέχεια αν το μωσαϊκό είναι τουλάχιστο 16x16 και αν οι διαστάσεις του διαιρούν ακριβώς την τρέχουσα ανάλυση. Αν όλα αυτά ισχύουν τότε κρατούνται αυτές οι διαστάσεις. -->>

	STDCALL RegOpenKeyExA,HKEY_LOCAL_MACHINE,RegKey,0,0,KeyHandle
	test eax,eax
	jne near .NoReg
	STDCALL RegQueryValueExA,[KeyHandle],0,0,0,RegVal,RegSize
	test eax,eax
	jne near .NoReg
	STDCALL RegCloseKey,[KeyHandle]

	mov eax,[DeskX]		; <<-- Έλεγχος X οθόνης και X μωσαϊκού για <16 ή υπόλοιπο από διαίρεση -->>
	mov ebx,[RegMW]
	xor dx,dx
	div bx
	cmp ax,3
	jb .NoReg
	cmp ax,17
	jnb .NoReg
	test dx,dx
	jne .NoReg
	mov eax,[DeskY]		; <<-- Έλεγχος Y οθόνης και Y μωσαϊκού για <16 ή υπόλοιπο από διαίρεση  -->>
	mov ebx,[RegMH]
	xor dx,dx
	div bx
	cmp ax,3
	jb .NoReg
	cmp ax,17
	jnb .NoReg
	test dx,dx
	je .n1
.NoReg:	push eax		; <<-- Αν κάτι πάει στραβά... -->>
	push Dword [DeskX]
	call Diver
	mov eax,[RegMH]
	mov [RegMW],eax
	push eax
	push Dword [DeskY]
	call Diver

   .n1:	; <<-- Δημιουργία μαύρου τετραγώνου πάνω-αριστερα στο Virtual παράθυρο. Εμφάνιση του κανονικού παραθύρου, αντιγραφή του Virtual παραθύρου στο κανονικό, εξαφάνιση του mouse. -->>

	STDCALL ShowWindow,[hWnd],SW_MAXIMIZE
	STDCALL GetStockObject,BLACK_BRUSH
	STDCALL SelectObject,[VirtDC],eax
	STDCALL PatBlt,[VirtDC],0,0,[RegMW],[RegMH],PATCOPY
	STDCALL GetDC,[hWnd]
	mov [hDC],eax
	STDCALL BitBlt,eax,0,0,[DeskX],[DeskY],[VirtDC],0,0,SRCCOPY
	STDCALL ReleaseDC,[hWnd],[hDC]
	STDCALL ShowCursor,0


; <<-- Ο βρόχος που δέχεται μυνήματα για το παράθυρο και τα ξαναστέλνει στα Windows -->>

MessageLoop:
	STDCALL Sleep,10
	STDCALL PeekMessageA,msg,0,0,0,PM_NOREMOVE	; <<-- Μη σταματάς για μύνημα -->>
	test eax,eax
	je MvRct
		STDCALL GetMessageA,msg,0,0,0
		test eax,eax
		je near Exit
		STDCALL DispatchMessageA,msg
		jmp MessageLoop

	; <<-- Εδώ όλοι οι έλεγχοι για την κίνηση του τετραγώνου -->>
 MvRct:
	cmp byte [IsMoving],1
	je OnMov
		; <<-- Επιλογή επομένου τετραγώνου που θα κινηθεί -->>
		STDCALL GetTickCount
		xor al,ah
		test al,2
		je .XMov
		mov ecx,4
		jmp .XYMov
	 .XMov:	xor ecx,ecx
	.XYMov:	call BoundCheck
		neg ecx
		mov edx,[CurBlackY+ecx]
		mov [MovingY+ecx],edx
		mov [NextY+ecx],edx
		mov byte [IsMoving],1
		jmp MessageLoop

		; <<-- Κίνηση του τετραγώνου -->>
	 OnMov:
		; <<-- Νέες συντεταγμένες για αποθήκευση στη στοίβα των συντεταγμένων γραμμής σβυσίματος -->>
		push Dword PATCOPY
		mov eax,[MovingX]	; <<-- Κίνηση στον άξονα X -->>
		cmp eax,[CurBlackX]
		je .mo1
		push Dword [RegMH]
		push Dword 1
		push Dword [CurBlackY]
		jb .mo2
		sub eax,1
		mov [MovingX],eax
		add eax,[RegMW]
		push eax
		jmp .mo3
	  .mo2:	push eax
		add eax,1
		mov [MovingX],eax
		jmp .mo3
	  .mo1:	push Dword 1		; <<-- Κίνηση στον άξονα Y -->>
		push Dword [RegMW]
		mov eax,[MovingY]
		cmp eax,[CurBlackY]
		jb .mo4
		sub eax,1
		mov [MovingY],eax
		add eax,[RegMH]
		push eax
		jmp .mo5
	  .mo4:	push eax
		add eax,1
		mov [MovingY],eax
	  .mo5:	push Dword [CurBlackX]

	  .mo3:	; <<-- Τυπώνω την κίνηση -->>
		STDCALL GetDC,[hWnd]
		mov [hDC],eax
		STDCALL GetStockObject,BLACK_BRUSH
		STDCALL SelectObject,[hDC],eax
		STDCALL BitBlt,[hDC],[MovingX],[MovingY],[RegMW],[RegMH],[VirtDC],[NextX],[NextY],SRCCOPY
		STDCALL PatBlt,[hDC]	; <<-- Οι άλλες παράμετροι έχουν καταχωριθεί ήδη στη στοίβα -->>

		; <<-- Έλεγχος για ολοκλήρωση της κίνησης -->>
		mov eax,[MovingX]
		cmp eax,[CurBlackX]
		jne .mo6
		mov eax,[MovingY]
		cmp eax,[CurBlackY]
		jne .mo6
		STDCALL BitBlt,[VirtDC],0,0,[DeskX],[DeskY],[hDC],0,0,SRCCOPY
		mov eax,[NextX]
		mov [CurBlackX],eax
		mov eax,[NextY]
		mov [CurBlackY],eax
		mov byte [IsMoving],0
	  .mo6:	STDCALL ReleaseDC,[hWnd],[hDC]
		jmp MessageLoop


; <<-- Το σημείο στο οποίο τα Windows στέλνουν τα μηνύματα για επεξεργασία -->>

WinProc:
	cmp message,WM_KEYDOWN		; <<-- Μήνυμα καταστροφής παραθύρου -->>
	je .ex
	cmp message,WM_RBUTTONDOWN	; <<-- Μήνυμα καταστροφής παραθύρου -->>
	je .ex
	cmp message,WM_LBUTTONDOWN	; <<-- Μήνυμα καταστροφής παραθύρου -->>
	je .ex
	cmp message,WM_DESTROY		; <<-- Μήνυμα καταστροφής παραθύρου -->>
	jne .def
   .ex:		STDCALL DeleteDC,[VirtDC]
		STDCALL DeleteObject,[Bmp]
		STDCALL PostQuitMessage,0
		xor eax,eax
		ret 16

.def:	STDCALL DefWindowProcA,STK(4),STK(8),STK(12),STK(16)	; <<-- Default διαχείρηση μηνύματος -->>
	ret 16




; <<-- Ελέγχει αν το τετράγωνο που επιλέχτηκε είναι μέσα στην οθόνη. Αν όχι διορθώνει. al: Διεύθυνση κίνησης edi: 0-X 4-Y. Επιστρέφεται edx: σωστή συντεταγμένη τετραγώνου για μετακίνηση -->>

BoundCheck:
	mov edx,[CurBlackX+ecx]
	test al,1
	je BCNe2
	add edx,[RegMW+ecx]
	jmp BCNe3
 BCNe2:	sub edx,[RegMW+ecx]
 BCNe3:	mov ebx,[RegMW+ecx]
	shl ebx,1
	cmp edx,[DeskX+ecx]
	je BCNe4
	jb BCNe1
	add edx,ebx
	jmp BCNe1
 BCNe4: sub edx,ebx
 BCNe1:	mov [NextX+ecx],edx
	mov [MovingX+ecx],edx
	ret