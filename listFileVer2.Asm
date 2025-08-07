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
	pathInput db "C:\Users\LuongTD\Downloads\loopFile\Input.txt", 0
	pathOutput db "C:\Users\LuongTD\Downloads\loopFile\Output.txt", 0
	errorPath dw 0050h, 0061h, 0074h, 0068h, 0020h, 0063h, 1ea7h, 006eh, 0020h, 0063h, 00f3h, 0020h, 0064h, 1ea5h, 0075h, 0020h, 005ch, 0020h, 1edfh, 0020h, 0063h, 0075h, 1ed1h, 0069h, 0020h, 0063h, 00f9h, 006eh, 0067h , 0
	enterFile dw 000Dh 
	errorFindFile dw 0046h, 006fh, 006ch, 0064h, 0065h, 0072h, 0020h, 006bh, 0068h, 00f4h, 006eh, 0067h, 0020h, 0074h, 1ed3h, 006eh, 0020h, 0074h, 1ea1h, 0069h, 0
	handleInput dd ?
	handleOutput dd ?
	data dw 1000 dup (0)
	dataInput dw 1000 dup (0)
	path dw 900 dup (0) ; Duong dan file
	extend dw 100 dup (0) ; Phan mo rong cua file
	fileInfor WIN32_FIND_DATA <>
	rank dd 0
	rankByte dw 002dh , 002dh , 0
	rankTmp dd 0
	checkEqu db 0
	bom dw 0FEFFh
;code segment
.code
checkExtend proc	
	call resetRegistryFunc
getLenExtend:
	cmp word ptr [extend + ecx] , 0
	je getLenName
	add ecx , 2
	jmp getLenExtend
getLenName:
	cmp word ptr [fileInfor.cFileName + ebx] , 0
	je compare
	add ebx , 2
	jmp getLenName
compare:
	sub ebx , 2
	sub ecx , 2
	cmp ecx , 0
	jl euq
	mov dx , word ptr [extend + ecx ]
	cmp dx , word ptr [fileInfor.cFileName + ebx]
	je compare
	mov byte ptr [checkEqu] , 0
	jmp endFunc
euq:
	mov byte ptr [checkEqu] , 1
	jmp endFunc
endFunc:
	ret

checkExtend endp
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
	
	
	push 0
	push 0
	push 2
	push offset bom
	push handleOutput
	call WriteFile
	
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
	call MessageBoxW 
	ret

printNoticeFunc endp
checkPathFunc proc ; Check Path
	call resetRegistryFunc 
getLen:
	cmp word ptr [path + ecx] , 0
	je check
	inc ecx
	jmp getLen
check:
	dec ecx
	cmp word ptr [path + ecx] , 005ch
	je endFunc
	push offset errorPath
	call printNoticeFunc
	push 0
	call ExitProcess  
endFunc:
	ret

checkPathFunc endp

writeInFileFunc proc 
	xor ecx , ecx
	mov dword ptr [rankTmp] , 0h
loopAddRank:
	mov ecx , dword ptr [rankTmp]
	cmp ecx , dword ptr [rank]
	je addNameFile
	inc dword ptr [rankTmp]
	push 0
	push 0
	push 4
	push offset rankByte
	push handleOutput
	call WriteFile
	jmp loopAddRank
addNameFile:
	call resetRegistryFunc
loopFindLen:
	cmp word ptr [fileInfor.cFileName + ecx] , 0
	je writeInFile
	add ecx , 2
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
	push 2
	push offset enterFile
	push handleOutput
	call WriteFile
	
	ret

writeInFileFunc endp
getListFileInFolderFunc proc
	LOCAL handleFolder: dword
	call resetRegistryFunc
loopPath:
	cmp word ptr [path + ecx] , 0
	je addStar
	add ecx , 2
	jmp loopPath
addStar:
	mov word ptr [path + ecx] , 002Ah ; dau *
	mov word ptr [path + ecx + 2], 0
	
	push 2 ; Toi uu khi tim kiem file
	push 0
	push 0
	push offset fileInfor
	push 1 ; lay nguyen ten va thuoc tinh thoi 
	push offset path
	call FindFirstFileExW

	cmp eax , -1
	je findFileError
	jmp findFileSuccess
findFileError:	
	call resetRegistryFunc
getLenPathNew:
	cmp word ptr [path + ecx] , 0
	je endProcError
	add ecx , 2
	jmp  getLenPathNew
endProcError:
	mov word ptr [path + ecx - 2] , 0
	ret
	
findFileSuccess:
	mov dword ptr [handleFolder] , eax
fileInFolder:
	call resetRegistryFunc
resetName: 
	;reset laij memory chuwa ten vi ten moi co the ngan hon ten cu
	cmp word ptr [fileInfor.cFileName + ecx] , 0
	je nextFileInfolder
	mov word ptr [fileInfor.cFileName + ecx] , 0
	add ecx , 2
	jmp resetName
nextFileInfolder:

	push offset fileInfor
	push handleFolder
	call FindNextFileW 
	cmp eax , 0
	
	
	je endFuncFind
	;;;;;;;
	
	;Check
    cmp word ptr [fileInfor.cFileName]  , 002eh
    je check
    jmp ok
check:
	cmp word ptr [fileInfor.cFileName + 2], 002eh
	je fileInFolder
	jmp ok
ok:
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
	jmp isFile
isFile:
	call checkExtend
	cmp byte ptr [checkEqu] , 1
	je equal
	jmp endIsFile 
equal:
	call writeInFileFunc
endIsFile:
	jmp fileInFolder
isFolder:

	call writeInFileFunc
	; Tao path cho folder moi
	call resetRegistryFunc
loopGetLenPath:
	cmp word ptr [path + ecx] , 0
	je pathNew
	add ecx , 2
	jmp loopGetLenPath
pathNew:
	cmp word ptr [fileInfor.cFileName + ebx] , 0
	je loopGetNewPath
	mov dx , word ptr [fileInfor.cFileName + ebx]
	mov word ptr [path + ecx - 2] ,  dx
	add ecx , 2
	add ebx , 2
	jmp pathNew	
loopGetNewPath:
	mov word ptr [path + ecx - 2] ,  005Ch
	inc dword ptr [rank]
	;de quy lap lai
	call getListFileInFolderFunc
	dec dword ptr [rank] 
;Khoi phuc lai path cu
	call resetRegistryFunc
getLen2:
	cmp word ptr [path + ecx] , 0
	je restore
	add ecx , 2
	jmp getLen2 
restore:
	sub ecx , 2 
	mov word ptr [path + ecx] , 0
	sub ecx , 2
restore2:
	cmp word ptr [path + ecx] , 005Ch
	je restore3
	mov word ptr [path + ecx] , 0
	sub ecx , 2
	jmp restore2
restore3:	
	add ecx , 2
	mov word ptr [path + ecx] , 002Ah
	jmp fileInFolder
endFuncFind:
	
	call resetRegistryFunc
getLenPathNew2:
	cmp word ptr [path + ecx] , 0
	je endProcError2
	add ecx , 2
	jmp  getLenPathNew2
endProcError2:
	mov word ptr [path + ecx - 2] , 0
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
	push offset data
	push handleInput
	call ReadFile 
	
	call resetRegistryFunc
	mov ecx , 2
newData:
	cmp word ptr [data + ecx] , 0
	je nextMain
	mov dx ,word ptr [data + ecx] 
	mov word ptr [dataInput +ebx] , dx
	add ebx , 2
	add ecx , 2
	jmp newData
nextMain:
	call resetRegistryFunc
getPath: ;Get Path
	cmp word ptr [dataInput + ecx] , 000Dh
	je getExtend
	mov dx , word ptr [dataInput + ecx]
	mov word ptr [path +ecx] , dx 
	add  ecx , 2
	jmp getPath
getExtend: ; Next /n and /r	
	add ecx , 4
getExtend2: ; Get Extend
	cmp word ptr [dataInput + ecx] , 0
	je body
	mov dx , word ptr [dataInput + ecx] 
	mov word ptr [extend + ebx] , dx
	add ebx , 2
	add ecx , 2
	jmp getExtend2
body: ; logic main for loop get all file
	call checkPathFunc ; Check path
	call getListFileInFolderFunc




EndProcess:
	push 0
	call ExitProcess 
end Main
