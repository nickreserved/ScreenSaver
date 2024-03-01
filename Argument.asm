	; <<-- Ελέγχος στο command line μέχρι να βρεθεί το " /" -->>

	STDCALL GetCommandLineA
.loop1:	cmp word [eax],' /'
	je .ne1
	inc eax
	cmp byte [eax],0
	jne .loop1

  .ne1:	add eax,2
	mov cl,[eax]
	cmp cl,'c'	; <<-- "/C" : Settings -->>
	je PSetup
	cmp cl,'C'
	je PSetup
	cmp cl,'a'	; <<-- "/A" : Password -->>
	je PPass
	cmp cl,'A'
	je PPass
	cmp cl,'p'	; <<-- "/P" : Preview -->>
	je near Exit
	cmp cl,'P'
	je near Exit
	jmp View

PSetup:	push Dword Setup
	jmp GoOn
PPass:	push Dword Pass
GoOn:	add eax,2
	push eax
	call String2Long
	mov [hWnd],eax
	ret




; <<-- Μετατροπή string σε Long. Παράμετρος: pointer στο κείμενο. Επιστρέφει: ο αριθμός -->>

String2Long:
	push edx
	push ecx
	push ebx
	mov ebx,[esp+4+3*4]
	xor eax,eax
	xor ecx,ecx
.St2L1:	mov cl,[ebx]
	sub cl,48
	cmp cl,10
	jb .Str2L
	pop ebx
	pop ecx
	pop edx
	ret 4
.Str2L:	mov edx,10
	mul edx
	add eax,ecx
	inc ebx
	jmp .St2L1