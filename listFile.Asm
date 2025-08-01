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
	folder db 100 dup (0)
	data db 1000 dup (0)
	extend db 100 dup (0)
	wfd WIN32_FIND_DATA <>
	rank db 1000 dup (0)
	checkByte db 1000 dup (0)
	enterFile db 13
.code
loopFile proc   ; ham nay duyet tat ca file trong 1 folder
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
	cmp eax , -1
	jne nextFindFirstFile
	ret
nextFindFirstFile:
	mov dword ptr [handleFind] , eax
doWhile:
	
	cmp byte ptr [wfd.cFileName] , "." ; neu ten file chua . thi bo qua tuc laf gom, . la file hien tai va .. se la file truoc do
	je next
	;;name ; logic nay se day ten file va rank cua no vao trong file
	call checkEqu
	cmp dword ptr [wfd.dwFileAttributes] , 00000010h
	je checkExtendTrue
	cmp byte ptr [checkByte] , 1
	je checkExtendTrue
	jmp checkExtendFalse
checkExtendTrue:
	;ghi vao file
	mov ecx , 0
lenRankI:
	cmp byte ptr [rank + ecx] , 0
	je addRankIn
	inc ecx
	jmp lenRankI
addRankIn:
	push 0
	push 0
	push ecx
	push offset rank
	push handleFileOutput
	call WriteFile
	
	mov ecx , 0
lenFileI:
	cmp byte ptr [wfd.cFileName + ecx] , 0
	je addFileIn
	inc ecx
	jmp lenFileI
addFileIn:

	push 0
	push 0
	push ecx
	push offset wfd.cFileName
	push handleFileOutput
	call WriteFile
	
	push 0
	push 0
	push 1
	push offset enterFile
	push handleFileOutput
	call WriteFile 
	;end ghi vao file	
	;;end name
checkExtendFalse: 
	cmp dword ptr [wfd.dwFileAttributes] , 00000010h ; neu file la folder 
	jne next ; neu khong phai thi duyet file tiep theop
	;lap den atribute moi
	
	;; luu handle vao mang
	;;+ level len
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
	;tru di level
	mov ecx , 0
tinhLen:
	cmp byte ptr [folder + ecx] , 0
	je restore
	inc ecx
	jmp tinhLen
restore:
	cmp byte ptr [folder +ecx] , "\"
	je endRestore
	mov byte ptr [folder + ecx] , 0
	dec ecx
	jmp restore
endRestore:
	mov byte ptr [folder + ecx] , 0
restore2:
	cmp byte ptr [folder + ecx] , "\"
	je endRestore2
	mov byte ptr [folder + ecx] , 0
	dec ecx
	jmp restore2
endRestore2:
	inc ecx
	mov byte ptr [folder + ecx] , "*"
	ret

loopFileNew endp

checkEqu proc ;ham check duoi giong nhau
	xor ecx , ecx 
	xor ebx , ebx
lenExtend:
	cmp byte ptr [extend + ecx] , 0
	je lenFile
	inc ecx
	jmp lenExtend
lenFile:
	cmp byte ptr [wfd.cFileName + ebx] , 0
	je nextCheckEqu
	inc ebx
	jmp lenFile
nextCheckEqu:
	cmp ecx , 0
	jl checkTrue
	mov dl , byte ptr [extend + ecx]
	cmp byte ptr [wfd.cFileName + ebx] , dl
	jne checkFalse
	dec ecx
	dec ebx 
	jmp nextCheckEqu
checkTrue:
	mov byte ptr [checkByte] , 1
	jmp endCheck
checkFalse:
	mov byte ptr [checkByte] , 0
	jmp endCheck
endCheck:	
	ret
checkEqu endp

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
	push 2
	push 0
	push 0
	push 4  ; append
	push offset fileNameOutput
	call CreateFile 
	mov dword ptr [handleFileOutput] , eax ; handle mo file output
	
	push 0
	push 0
	push 1000 
	push offset data
	push handleFileInput
	call ReadFile ; Doc noi dung file 
	
	
	xor ecx , ecx
	xor ebx , ebx
getFolder:
	cmp byte ptr [data + ecx] , 13
	je NextGetExtend
	mov al , byte ptr [data + ecx]
	mov byte ptr [folder + ecx] , al
	inc ecx
	jmp getFolder
NextGetExtend:
	add ecx , 2
getExtend:
	cmp byte ptr [data + ecx] , 0
	je endProgram
	mov al , byte ptr [data + ecx]
	mov byte ptr [extend + ebx] , al
	inc ebx
	inc ecx
	jmp getExtend
	
endProgram:
	call loopFile ; goi ham duyet folder
	
	push 0
	call ExitProcess 
end start
