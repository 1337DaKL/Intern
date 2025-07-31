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
	rank db 10000 dup (0)
.code
loopFile proc  : ; ham nay duyet tat ca file trong 1 folder
 	LOCAL handleFind: dword
startFuncFile:
 	mov ecx , 0
loopadd: ; tim vi tri cuoi cung trong ten cua folder
	cmp  byte ptr [folder + ecx] , 0
	je addEnd
	mov al , byte ptr [folder + ecx]
	inc ecx
	jmp loopadd
addEnd: ; them /* de dung lofic findFistFile
	mov byte ptr [folder + ecx] , '\'
	inc ecx
	mov byte ptr [folder + ecx] , '*'
	inc ecx
	mov byte ptr [folder + ecx] , 0
	
	push offset wfd
	push offset folder 
	call FindFirstFile 
	mov dword ptr [handleFind] , eax
	doWhile:
	
	cmp byte ptr [wfd.cFileName] , "." ; neu ten file chua . thi bo qua tuc laf gom, . la file hien tai va .. se la file truoc do
	je next
	
	;;name ; logic nay se day ten file va rank cua no vao trong file
	push 0
	push 0
	push offset rank
	push 0
	call MessageBox
	
	push 0
	push 0
	push offset wfd.cFileName
	push 0
	call MessageBox
	;;end name
	cmp dword ptr [wfd.dwFileAttributes] , 00000010h ; neu file la folder 
	jne next ; neu khong phai thi duyet file tiep theop
	;lap den atribute moi
	push offset wfd.cFileName
	call loopFileNew ; neu la folder thi goi logic duyet folder tiep theo
	mov ecx , 0
loopEndRank:
	cmp byte ptr [rank + ecx] , 0 ; sau khi duyet folder moi xong thi giam rank xuong 1 bac
	je subRank
	inc ecx
	jmp loopEndRank
subRank: ; loic giam rank di mot bac
	dec ecx
	mov byte ptr [rank +ecx] , 0
	dec ecx
	mov byte ptr [rank +ecx] , 0
	;end lap den atribute moi
	next: ; duyet file tiep theo
	push offset wfd
	push handleFind
	call FindNextFile 
	
	cmp eax , 0
	je endProc
	jmp doWhile
endProc: ; ket thuc ham
	ret
loopFile endp

loopFileNew proc nameFileNew:dword ;Ham nay de quy tiep tuc duyet folder con 
	mov ecx , 0
resetRank: ;rank them cap bac
	cmp byte ptr [rank + ecx] , 0
	je startLoopFileChild
	inc ecx
	jmp resetRank
startLoopFileChild:
	mov byte ptr [rank +ecx] , "-"
	inc ecx 
	mov byte ptr [rank + ecx] , "-"
	mov ecx , 0
	mov ebx , 0
loopFindEnd1:; Sau do tim vi tri cuoi cung cua folder
	cmp byte ptr [folder + ecx] , 0
	je nextLoopFileNew
	inc ecx
	jmp loopFindEnd1
nextLoopFileNew:
	sub ecx , 1

loopAddString: ;tien hanh cong vao ten folder moi 
	mov edx , dword ptr [nameFileNew]
	add edx , ebx
	cmp byte ptr [edx] , 0
	je endLoopFileNew
	mov al , byte ptr [edx]
	mov byte ptr [folder + ecx] , al
	inc ecx 
	inc ebx
	jmp loopAddString
endLoopFileNew:
	mov byte ptr [folder + ecx ], 0
	call loopFile ; goi lai ham duyet file
	ret

loopFileNew endp

start: ;ham main
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
	push 0C0000000h ; gom ca quyen doc va ghi
	push offset fileNameInput
	call CreateFile 
	mov dword ptr [handleFileInput] , eax ; handle mo file input
	
	push 0
	push 128
	push 3
	push 0
	push 0
	push 0C0000000h  ; gom ca quyen doc va ghi
	push offset fileNameOutput
	call CreateFile 
	mov dword ptr [handleFileOutput] , eax ; handle mo file output
	
	push 0
	push 0
	push 1000 
	push offset folder
	push handleFileInput
	call ReadFile ; Doc noi dung file 
	
	call loopFile ; goi ham duyet folder
	
endProgram:
	push 0
	call ExitProcess 
end start
