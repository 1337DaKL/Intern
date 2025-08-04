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
	enterFile db 13 
	errorFindFile db "Folder khong ton tai", 0
	handleInput dd ?
	handleOutput dd ?
	dataInput db 1000 dup (0)
	path db 900 dup (0) ; Duong dan file
	extend db 100 dup (0) ; Phan mo rong cua file
	fileInfor WIN32_FIND_DATA <>
	rank dd 0
	rankByte db "--" , 0
	rankTmp dd 0
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
	push 2
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
	mov byte ptr [path + ecx + 1], 0
	
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
	call resetRegistryFunc
getLenPathNew:
	cmp byte ptr [path + ecx] , 0
	je endProcError
	inc ecx
	jmp  getLenPathNew
endProcError:
	mov byte ptr [path + ecx - 1] , 0
	ret
findFileSuccess:
	
	mov dword ptr [handleFolder] , eax
fileInFolder:	
	push offset fileInfor
	push handleFolder
	call FindNextFile 
	cmp eax , 0
	je endFuncFind
	;;;;;;;
	
	;Check
    cmp byte ptr [fileInfor.cFileName]  , "."
    je check
    jmp ok
check:
	cmp byte ptr [fileInfor.cFileName + 1], "."
	je fileInFolder
	jmp ok
ok:
	xor ecx , ecx
	mov dword ptr [rankTmp] , 0h
loopAddRank:
	mov ecx , dword ptr [rankTmp]
	cmp ecx , dword ptr [rank]
	je addNameFile
	inc dword ptr [rankTmp]
	push 0
	push 0
	push 2
	push offset rankByte
	push handleOutput
	call WriteFile
	jmp loopAddRank
addNameFile:
	call resetRegistryFunc
loopFindLen:
	cmp byte ptr [fileInfor.cFileName + ecx] , 0
	je writeInFile
	inc ecx
	jmp loopFindLen
writeInFile:
	
	push 0
	push 0
	push ecx
	push offset fileInfor.cFileName
	push handleOutput
	call WriteFile 
	
	push 0
	push 0
	push 1
	push offset enterFile
	push handleOutput
	call WriteFile 
	
	cmp dword ptr [fileInfor.dwFileAttributes] , 16h ; vua la fodler vua la file an vua la folder he thong
	je isFolder
	cmp dword ptr [fileInfor.dwFileAttributes] , 11h ; vua la folder vua la file chi duoc doc
	je isFolder
	cmp dword ptr [fileInfor.dwFileAttributes] , 10h ; la folder
	je isFolder
	cmp dword ptr [fileInfor.dwFileAttributes] , 12h; la folder va bi an
	je isFolder
	cmp dword ptr [fileInfor.dwFileAttributes] , 31h ; folder ,  chi doc , dung de luu tru
	je isFolder
	cmp dword ptr [fileInfor.dwFileAttributes] , 17h ; folder ,  chi doc , dung de luu tru
	je isFolder	
	cmp dword ptr [fileInfor.dwFileAttributes] , 18h ; folder ,  chi doc , dung de luu tru
	je isFolder	
	cmp dword ptr [fileInfor.dwFileAttributes] , 00002416h ; folder ,  onedrove
	je isFolder	
	cmp dword ptr [fileInfor.dwFileAttributes] , 00002010h ; folder ,  ondrive
	je isFolder	
	cmp dword ptr [fileInfor.dwFileAttributes] , 00000431h ; chi doc, danh dau luu tru , mo moi tai ve
	je isFolder	
	jmp fileInFolder
isFolder:
	; Tao path cho folder moi
	call resetRegistryFunc
loopGetLenPath:
	cmp byte ptr [path + ecx] , 0
	je pathNew
	inc ecx 
	jmp loopGetLenPath
pathNew:
	cmp byte ptr [fileInfor.cFileName + ebx] , 0
	je loopGetNewPath
	mov dl , byte ptr [fileInfor.cFileName + ebx]
	mov byte ptr [path + ecx - 1] ,  dl
	inc ecx 
	inc ebx
	jmp pathNew	
loopGetNewPath:
	mov byte ptr [path + ecx - 1] ,  "\"
	inc dword ptr [rank]
	;de quy lap lai
	call getListFileInFolderFunc
	dec dword ptr [rank] 
;Khoi phuc lai path cu
	call resetRegistryFunc
getLen2:
	cmp byte ptr [path + ecx] , 0
	je restore
	inc ecx
	jmp getLen2 
restore:
	dec ecx 
	mov byte ptr [path + ecx] , 0
	dec ecx
restore2:
	cmp byte ptr [path + ecx] , "\"
	je restore3
	mov byte ptr [path + ecx] , 0
	dec ecx
	jmp restore2
restore3:	
	inc ecx
	mov byte ptr [path + ecx] , "*"
	jmp fileInFolder
endFuncFind:
	
	call resetRegistryFunc
getLenPathNew2:
	cmp byte ptr [path + ecx] , 0
	je endProcError2
	inc ecx
	jmp  getLenPathNew2
endProcError2:
	mov byte ptr [path + ecx - 1] , 0
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
