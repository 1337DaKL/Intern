.386
.model flat, stdcall  ;32 bit memory model
.stack 100h
option casemap :none  ;case sensitive
include user32.inc
include kernel32.inc
include IO.asm
;include tinhfunction.asm
; Directives for the linker to link libraries
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
.data
	pathFileInput db "E:\malware document\TinhTongHaiSo\Input.txt" , 0
	handleFile dd ?
	posEnd1 dd ?
	posEnd2 dd ?
	posMid dd ?
	real dd ?
	byteFile db ?
	remember db ?
.code
start:
	call reset
	;tim vi tri chuoi thu 2
	push 0
	push 128
	push 3
	push 0
	push 0
	push 80000000h
	push offset pathFileInput
	call CreateFile ; Mo file input
	mov dword ptr [handleFile] , eax ; lay handle file
	
	push 2
	push 0
	push 0
	push handleFile
	call SetFilePointer ; di chuyen con tro toi cuoi file
	dec eax
	mov dword ptr [posEnd2], eax ; lay vi tri cuoi file va cung la cij tri cuoi cua chuoi thu hai
	
	push 0
	push 0
	push 0
	push handleFile
	call SetFilePointer ; chuyen ve vi tri dau tien de tien hanh duyet file
	
	mov ebx , 0 
loopFindPos:
	push 0
	push 0
	push ebx
	push handleFile
	call SetFilePointer ; lap tung byte trong file
	
	push 0
	push offset real 
	push 1
	push offset byteFile
	push handleFile
	call ReadFile
	
	cmp byte ptr [byteFile] , 20h
	je endLoopFindPos
	
	inc ebx
	jmp loopFindPos
endLoopFindPos:
	mov dword ptr [posMid] , ebx
	dec ebx
	mov dword ptr [posEnd1] , ebx
	call reset
	
	;; logic cong
loopSum:
	cmp dword ptr [posEnd1] , 0
	jl logicSum1
	cmp postEnd2 , posMid
	je logicSum2
	push 0
	push 0
	push posEnd1
	push handleFile 
	call SetFilePointer 
	
	push 0
	push offset real
	push 1
	push offset byteFile
	push handleFile
	call ReadFile 
	
	mov bl , byte ptr [byteFile]
	sub bl , '0'
	
	push 0
	push 0
	push posEnd2
	push handleFile 
	call SetFilePointer 
	
	push 0
	push offset real
	push 1
	push offset byteFile
	push handleFile
	call ReadFile 
	
	mov al , byte ptr [byteFile]
	sub al , '0'
	add al , bl
	
	mov dl , 10
	xor ah , ah
	div dl
	
	mov byte ptr [remember] , al
	;logic ghi vao file
	
	;end logic ghi vao file
	
	mov eax , dword ptr [posEnd1]
	dec eax
	mov dword ptr [posEnd1] , eax
	
	mov eax , dword ptr [posEnd2]
	dec eax
	mov dword ptr [posEnd2], eax

logicSum1:
	cmp posEnd2 , posMid
	je endProgram
	push 0
	push 0
	push posEnd2
	push handleFile
	call SetFilePointer 
	
	push 0
	push offset real
	push 1
	push offset byteFile
	push handleFile
	call ReadFile 
	
	mov al , byte ptr [byteFile]
	sub al , '0'
	cmp remember , 1
	je call addRemember
	
	mov dl , 10
	xor ah , ah
	div dl
	mov byte ptr [remember] , al
	
	mov eax , dword ptr [posEnd2]
	dec eax
	mov dword ptr [posEnd2], eax
	jmp logicSum1
logicSum2:
endProgram:
	push 0
	call ExitProcess
addRemember:
	inc al
	ret
reset:
	xor eax , eax
	xor ebx , ebx
	xor ecx , ecx
	xor edx , edx
	ret
end start
