.386
.model flat, stdcall  
.stack 100h
option casemap :none  
include user32.inc
include kernel32.inc
include windows.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
;data segment
.data
	pathInput db "E:\malware document\loopFile\Input.txt", 0
	pathOutput db "E:\malware document\loopFile\Output.txt", 0
	errorPath db "Path can co dau \ o cuoi cung" , 0
	errorFindFile db "Folder khong ton tai", 0
	handleInput dd ?
	handleOutput dd ?
	dataInput db 1000 dup (0)
	path db 900 dup (0) ; Duong dan file
	extend db 100 dup (0) ; Phan mo rong cua file
	fileInfor WIN32_FIND_DATA <>
;code segment
.code
openFileFunc proc ;OpenFile
	push 0
	push 128
	push 3
	push 0
	push 0
	push 0C0000000h
	push offset pathInput
	call CreateFile 
	mov dword ptr [handleInput], eax
	
	push 0
	push 128
	push 3
	push 0
	push 0
	push 4
	push offset pathOutput
	call CreateFile 
	mov dword ptr [handleOutput], eax
	
	ret

openFileFunc endp

resetRegistryFunc proc ; Reset Registry
	
	xor eax , eax
	xor ebx , ebx
	xor ecx , ecx
	xor edx , edx
	ret

resetRegistryFunc endp
printNoticeFunc proc dataNotice: dword ; Display Notice
	push 0
	push 0
	push dataNotice
	push 0
	call MessageBox 
	ret

printNoticeFunc endp
checkPathFunc proc ; Check Path
	call resetRegistryFunc 
getLen:
	cmp byte ptr [path + ecx] , 0
	je check
	inc ecx
	jmp getLen
check:
	dec ecx
	cmp byte ptr [path + ecx] , "\"
	je endFunc
	push offset errorPath
	call printNoticeFunc
	push 0
	call ExitProcess  
endFunc:
	ret

checkPathFunc endp

getListFileInFolderFunc proc
	LOCAL handleFolder: dword
	call resetRegistryFunc
loopPath:
	cmp byte ptr [path + ecx] , 0
	je addStar
	inc ecx
	jmp loopPath
addStar:
	mov byte ptr [path + ecx] , "*"
	
	push 2 ; Toi uu khi tim kiem file
	push 0
	push 0
	push offset fileInfor
	push 1 ; lay nguyen ten va thuoc tinh thoi 
	push offset path
	call FindFirstFileEx 
	cmp eax , -1
	je findFileError
	jmp findFileSuccess
findFileError:
	push offset errorFindFile
	call printNoticeFunc 
	push 0
	call ExitProcess 
findFileSuccess:
	
	mov dword ptr [handleFolder] , eax
fileInFolder:	
	push offset fileInfor
	push handleFolder
	call FindNextFile 
	cmp eax , 0
	je endFuncFind
	;Write In file
	
	;Next
	
	jmp fileInFolder
endFuncFind:
	ret

getListFileInFolderFunc endp

;main
Main:
	;Open File
	call openFileFunc
	
	;Read data
	push 0
	push 0
	push 1000
	push offset dataInput
	push handleInput
	call ReadFile 
	
	call resetRegistryFunc
getPath: ;Get Path
	cmp byte ptr [dataInput + ecx] , 13
	je getExtend
	mov dl , byte ptr [dataInput + ecx]
	mov byte ptr [path +ecx] , dl 
	inc ecx
	jmp getPath
getExtend: ; Next /n and /r	
	add ecx , 2
getExtend2: ; Get Extend
	cmp byte ptr [dataInput + ecx] , 0
	je body
	mov dl , byte ptr [dataInput + ecx] 
	mov byte ptr [extend + ebx] , dl
	inc ecx
	inc ebx
	jmp getExtend2
body: ; logic main for loop get all file
	call checkPathFunc ; Check path
	call getListFileInFolderFunc




EndProcess:
	push 0
	call ExitProcess 
end Main
