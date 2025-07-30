.386
.model flat, stdcall  ;32 bit memory model
.stack 100h
option casemap :none  ;case sensitive
include user32.inc
include kernel32.inc
;include tinhfunction.asm
; Directives for the linker to link libraries
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
WIN32_FIND_DATA STRUCT
  dwFileAttributes      dd ?
  ftCreationTime        dq ?
  ftLastAccessTime      dq ?
  ftLastWriteTime       dq ?
  nFileSizeHigh         dd ?
  nFileSizeLow          dd ?
  dwReserved0           dd ?
  dwReserved1           dd ?
  cFileName             db 256 dup(?)
  cAlternateFileName    db 14 dup(?)
WIN32_FIND_DATA ENDS
.data
	fileNameInput db "C:\Users\LuongTD\Downloads\loopFile\Input.txt" , 0
	fileNameOutput db "C:\Users\LuongTD\Downloads\loopFile\Output.txt" , 0
	handleFileInput dd ?
	handleFileOutput dd ?
	folder db 1000 dup (0)
	wfd WIN32_FIND_DATA <>
.code
loopFile proc 
 	LOCAL handleFind: dword
 	LOCAL fileNew : byte
 	mov ecx , 0
loopadd:
	cmp  byte ptr [folder + ecx] , 0
	je addEnd
	mov al , byte ptr [folder + ecx]
	inc ecx
	jmp loopadd
addEnd:
	mov byte ptr [folder + ecx] , '\'
	inc ecx
	mov byte ptr [folder + ecx] , '*'
	inc ecx
	mov byte ptr [folder + ecx] , 0
	push 0
	push 0
	push offset folder
	push 0
	call MessageBox 
	
	push offset wfd
	push offset folder 
	call FindFirstFile 
	mov dword ptr [handleFind] , eax
	doWhile:
	
	cmp byte ptr [wfd.cFileName] , "."
	je next
	
	push 0
	push 0
	push offset wfd.cFileName
	push 0
	call MessageBox 
	cmp dword ptr [wfd.dwFileAttributes] , 00000010h
	jne next
	;lap den atribute moi
	push offset wfd.cFileName
	call loopFileNew
	;end lap den atribute moi
	next:
	push offset wfd
	push handleFind
	call FindNextFile 
	
	cmp eax , 0
	je endProc
	jmp doWhile
endProc:
	ret
loopFile endp
loopFileNew proc nameFileNew:dword
	push 0
	push 0
	push offset folder
	push 0
	call MessageBox 
	mov ecx , 0
	mov ebx , 0
loopFindEnd1:
	cmp byte ptr [folder + ecx] , 0
	je nextLoopFileNew
	inc ecx
	jmp loopFindEnd1
nextLoopFileNew:
	sub ecx , 2
	cmp byte ptr [folder + ecx] , "\"
	inc ecx
loopAddString:
	cmp byte ptr [nameFileNew + ebx] , 0
	je endLoopFileNew
	mov al , byte ptr [nameFileNew + ebx]
	mov byte ptr [folder + ecx] , al
	inc ecx 
	inc ebx
endLoopFileNew:
	push 0
	push 0
	push offset folder
	push 0
	call MessageBox 
	ret

loopFileNew endp
start:
	push offset fileNameInput
	xor eax , eax 
	xor ebx , ebx
	xor ecx , ecx
	xor edx , edx
	push 0
	push 128
	push 3
	push 0
	push 0
	push 0C0000000h 
	push offset fileNameInput
	call CreateFile 
	mov dword ptr [handleFileInput] , eax
	
	push 0
	push 128
	push 3
	push 0
	push 0
	push 0C0000000h 
	push offset fileNameOutput
	call CreateFile 
	mov dword ptr [handleFileOutput] , eax
	
	push 0
	push 0
	push 1000 
	push offset folder
	push handleFileInput
	call ReadFile 
	
	call loopFile
	
endProgram:
	push 0
	call ExitProcess 
end start
