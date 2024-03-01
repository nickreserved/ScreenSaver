	STDCALL DialogBoxParamA,0,IDD_DIALOG,[hWnd],DialogFunc,0	; �������� ��� Dialog ��� ���������
	jmp Exit



; <<-- � ��������� ����������� ��������� ��� Dialog -->>

DialogFunc:

	; <<-- Initializing... Combo Box, Text Box �.�.�. -->>
	cmp message,WM_INITDIALOG
	jne DFn1
		call Resolution
		push Dword IDC_SCREEN_Y
		push eax
		call Diver
		push Dword IDC_SCREEN_X
		push Dword [DeskX]
		call Diver
		jmp Term1



	; <<-- ������ ��� Button -->>
  DFn1:	cmp message,WM_COMMAND
	je Next1
 ToWin:	xor eax,eax
	ret

	 Next1:	mov eax,wParam
		cmp ax,IDCANCEL		; <<-- Button Cancel -->>
		jne Next2
		  Term:	STDCALL EndDialog,STK(4),0
		 Term1:	mov eax,1
			ret


	 Next2: cmp ax,IDOK		; <<-- Button Ok -->>
		jne ToWin
			STDCALL RegCreateKeyA,HKEY_LOCAL_MACHINE,RegKey,KeyHandle
			test eax,eax
			jne Term
			STDCALL SendDlgItemMessageA,STK(4),IDC_SCREEN_X,CB_GETCURSEL,0,0
			STDCALL SendDlgItemMessageA,STK(4),IDC_SCREEN_X,CB_GETITEMDATA,eax,0
			mov [RegMW],eax
			STDCALL SendDlgItemMessageA,STK(4),IDC_SCREEN_Y,CB_GETCURSEL,0,0
			STDCALL SendDlgItemMessageA,STK(4),IDC_SCREEN_Y,CB_GETITEMDATA,eax,0
			mov [RegMH],eax
			STDCALL RegSetValueExA,[KeyHandle],0,0,REG_BINARY,RegVal,8
			STDCALL RegCloseKey,[KeyHandle]
			jmp Term



; <<-- ������� ���������� ���������� ��� �� ��������� ��� ��� ����� ��� Combo Boxes. ����������: �������, ID ��� Combo -->>

Diver:	mov bx,3
	mov Dword [DeskWnd],0
  div2:	mov eax,[esp+4]	; <<-- �� ������� ������� ��� ���������� ��� ������ -->>
	xor dx,dx
	div bx
	test dx,dx
	jne div1
	mov [RegMH],eax
	STDCALL wsprintfA,AllBSS,SymStr,eax
	add esp,3*4
	STDCALL SendDlgItemMessageA,STK(16),STK(8),CB_ADDSTRING,0,AllBSS
	STDCALL SendDlgItemMessageA,STK(16),STK(8),CB_SETITEMDATA,[DeskWnd],[RegMH]
	inc Dword [DeskWnd]
  div1:	inc bx
	cmp bx,17
	jb div2
	STDCALL SendDlgItemMessageA,STK(16),STK(8),CB_SETCURSEL,0,0
	ret 8