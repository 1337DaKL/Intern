.386
.model flat, stdcall  
.stack 100h
option casemap :none  
include user32.inc
include kernel32.inc
include windows.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
.data
	pathInput db "C:\Program Files\Google\Chrome\Application\chrome.exe",0
	pathOutput db "D:\\Code\\Homework Intern\\PE Fomat\\Results.txt" , 0	    
	handleInput dd ?
	handleOutput dd ?
	data db 100 dup (0)
	ennter db 0Dh 
	one db ?
	two db ?
	three db ?
	four db ?
	by dw 16 dup (0)
	pe db "PE: " , 0
	sectionInfor db "SectionInfor: " , 0Dh, 0 
	numnerOfSection db "NumnerOfSection: " , 0
	imageBase db "ImageBase: " , 0
	ep db "EP: " , 0
	virtualSize db "VirtualSize: " , 0
	virtualAddress db "VirtualAddress: " , 0
	rawAddress db "RawAddress: ", 0
	rawSize db "RawSize: ", 0
	reloc db "Reloc Table: " , 0
	iat db "IAT Table: ", 0
	eat db "EAT Table: ", 0 
	moduleName db "Module Name: ",0
	OFTs db "OFTs: ", 0
	Time db "TimeDateStamp: ",0
	ForwarderChain db "ForwarderChain: ", 0
	NameRVA db "Name RVA: " , 0
	fts db "FTs (IAT): ", 0
	mid db " = " , 0
	phay db 22h ;dau "
	magic dw ?
	ifanview dw ?
	ngan db "---------------------------------------" , 0Dh , 0
	rva db 4 dup (0)
	virtualAddressSection db 4 dup (0)
	virtualSizeSection db 4 dup (0)
	rawAddressSection db 4 dup (0)
	rawSizeSection db 4 dup (0)
	maxSize db 4 dup (0)
	offsetAddress db 4 dup (0)
	offsetImport db 4 dup (0)
	ofts db 4 dup (0)
	timeDateStamp db 4 dup (0)
	forwarderChain db 4 dup(0)
	nameRva db 4 dup (0)
	iatImport db 4 dup (0)
	nameDll db 100 dup (0)
	stt dd 0
	index dd 0
	offsetOFT db 4 dup (0)
	cntFunc dw 0;
	offsetName db 4 dup (0)
	ofsFunc db 4 dup (0)
	offsetFunc db 4 dup (0)
	hint db 2 dup(0)
	nameFunc db 100 dup (0)
	index2 dd 0
	addressOfFunction db 4 dup (0)
	addressOfNames db 4 dup (0)
	addressOfNameOrdinals db 4 dup (0)
	numberOfFunction dd ?
	numberOfNames dd ?
	functionRVA db 4 dup (0)
	nameExportFunction db 100 dup (0)
	index3 dd 0
	a1 db "Characteristics: ",0
	a2 db "TimeDateStamp: " , 0
	a3 db "MajorVerion: " , 0
	a4 db "MinorVersion: " , 0
	a5 db "Name: ", 0
	a6 db "Base: ", 0
	a7 db "NumberOfFuntions: ", 0
	a8 db "NumberOfNames: " , 0
	a9 db "AddressOfFuntions: " , 0
	a10 db "AddressOfNames: ", 0
	a11 db "AddressOfNameOrdinals: ", 0
	a12 db "Function RVA: " , 0
	a13 db "Name Ordinal: " , 0
	a14 db "Name RVA: ", 0
	a15 db "Name: ", 0
	rvaReloc db 4 dup (0)
	offsetReloc dd ?
	sizeOfBlock db 4 dup (0)
	item db 4 dup (0)
	typeItem db 4 dup (0)
	rvaRelocDec db 4 dup (0)
	absolute db "ABSOLUTE", 0
	highbase db "HIGH", 0
	lowbase db "LOW", 0
	highlow db "HIGHLOW" , 0
	dir64 db "DIR64" , 0
.code
convertRvaToOffset proc
	push 0
	push 0
	push dword ptr [ifanview]
	push dword ptr [handleInput]
	call SetFilePointer ; di chuyen den fe header
	
	cmp word ptr [magic] ,  010Bh
 	je iiss32bit
 	jmp iiss64bit
iiss32bit:
	push 1
 	push 0
 	push 248
 	push dword ptr [handleInput]
 	call SetFilePointer
 	jmp DirecInSection
iiss64bit :	
	push 1
 	push 0
 	push 264
 	push dword ptr [handleInput]
 	call SetFilePointer
DirecInSection:
	push 1
	call readByte 
	cmp byte ptr [data] , 0 ; doc byte dau dtien de kiem tra xem có phai ket thuc section table chua 
	je notExits
	push 1
	push 0
	push 7
	push dword ptr [handleInput]
	call SetFilePointer ; bo qua phan ten 
	;lan luot lay cac dia chi va kich thuwc
	push 4
	call readByte 
	
	mov edx ,  dword ptr [data]
	mov dword ptr [virtualSizeSection] , edx
	
	push 4 
	call readByte 
	
	mov edx , dword ptr [data]
	mov dword ptr [virtualAddressSection] , edx
	
	push 4
	call readByte 
	mov edx , dword ptr [data]
	mov dword ptr [rawSizeSection ] , edx 
	
	push 4
	call readByte 
	mov edx , dword ptr [data]
	mov dword ptr [rawAddressSection] , edx
	
	push 1
	push 0 
	push 16 
	push dword ptr [handleInput]
	call SetFilePointer ; bo qua cac byte khong dung toi 
	
	mov edx , dword ptr [rva]
	cmp edx , dword ptr [virtualAddressSection] ; so sanh rva voi dia chi ao tuong doi 
	jl DirecInSection ; neu no  nho hon thi no khong nam trong section nay va bo qua
	call getMaxSize ; neu khong thi lay do lon nhat giua size ao va size raw 
	mov edx , dword ptr [virtualAddressSection] ; sau do dung cong thuc dia chi ao tuong sdoi + max (sizevirtual , sizeraw)
	add edx , dword ptr [maxSize] ; add
	cmp dword ptr [rva] , edx  ; so sanh voi eva
	jnl DirecInSection ; neu no >= rva thi no khong nam trong sectipon
	; neu no nam trong sex tion nay thi ap dung cong thuc offset = rva - rva cua section + dia chi tcua sextion trong dia
	mov edx , dword ptr [rva]
	sub edx , dword ptr [virtualAddressSection]
	add edx , dword ptr [rawAddressSection]
	mov dword ptr [offsetAddress] , edx ; tim duowc offset
	
	ret

convertRvaToOffset endp
getMaxSize proc
	mov edx , dword ptr [virtualSizeSection]
	cmp edx , dword ptr [rawSizeSection]
	jl rawMax
	jmp virtualMax
rawMax:
	mov edx , dword ptr [rawSizeSection]
	mov dword ptr [maxSize] , edx 
	jmp endFunc
virtualMax:
	mov edx , dword ptr [virtualSizeSection]
	mov dword ptr [maxSize] , edx
	jmp endFunc
endFunc:
	ret

getMaxSize endp

middleCompartment proc 
	
	push 40
	push offset ngan
	call write
	ret

middleCompartment endp
convertHexToAski proc
	mov eax , dword ptr [data]
	mov byte ptr [four] , al
	mov byte ptr [three] , ah
	shr eax , 16 ;dich 16 bit tuc la dich 2 byte vi 1 byte = 8 bit
	mov byte ptr [two] , al
	mov byte ptr [one] , ah
	
	mov al , byte ptr [one]
	mov ah , al
	shr ah , 4 ; dich 4 bit de xoa so thu 2 lay duoc so thu nhat
	and al , 0Fh ; and de lay so 2 vi chi so nao 1 thi moi bang 1
	cmp ah , 10
	jl isDigit1
	jmp isAlpha1
isDigit1:
	add ah , "0"
	jmp next1
isAlpha1:
	sub ah , 10
	add ah , "A"
	jmp next1
next1:
	cmp al , 10
	jl isDigit2
	jmp isAlpha2
isDigit2:
	add al , "0"
	jmp next2
isAlpha2:
	sub al , 10
	add al , "A"
	jmp next2
next2:
	mov byte ptr [by + 0] , ah
	mov byte ptr [by + 1] , al
	
	mov al , byte ptr [two]
	mov ah , al
	shr ah , 4 ; dich 4 bit de xoa so thu 2 lay duoc so thu nhat
	and al , 0Fh ; and de lay so 2 vi chi so nao 1 thi moi bang 1
	cmp ah , 10
	jl isDigit3
	jmp isAlpha3
isDigit3:
	add ah , "0"
	jmp next3
isAlpha3:
	sub ah , 10
	add ah , "A"
	jmp next3
next3:
	cmp al , 10
	jl isDigit4
	jmp isAlpha4
isDigit4:
	add al , "0"
	jmp next4
isAlpha4:
	sub al , 10
	add al , "A"
	jmp next4
next4:
	mov byte ptr [by + 2] , ah
	mov byte ptr [by + 3] , al
	
	mov al , byte ptr [three]
	mov ah , al
	shr ah , 4 ; dich 4 bit de xoa so thu 2 lay duoc so thu nhat
	and al , 0Fh ; and de lay so 2 vi chi so nao 1 thi moi bang 1
	cmp ah , 10
	jl isDigit5
	jmp isAlpha5
isDigit5:
	add ah , "0"
	jmp next5
isAlpha5:
	sub ah , 10
	add ah , "A"
	jmp next5
next5:
	cmp al , 10
	jl isDigit6
	jmp isAlpha6
isDigit6:
	add al , "0"
	jmp next6
isAlpha6:
	sub al , 10
	add al , "A"
	jmp next6
next6:
	mov byte ptr [by + 4] , ah
	mov byte ptr [by + 5] , al
	
	mov al , byte ptr [four]
	mov ah , al
	shr ah , 4 ; dich 4 bit de xoa so thu 2 lay duoc so thu nhat
	and al , 0Fh ; and de lay so 2 vi chi so nao 1 thi moi bang 1
	cmp ah , 10
	jl isDigit7
	jmp isAlpha7
isDigit7:
	add ah , "0"
	jmp next7
isAlpha7:
	sub ah , 10
	add ah , "A"
	jmp next7
next7:
	cmp al , 10
	jl isDigit8
	jmp isAlpha8
isDigit8:
	add al , "0"
	jmp next8
isAlpha8:
	sub al , 10
	add al , "A"
	jmp next8
next8:
	mov byte ptr [by + 6] , ah
	mov byte ptr [by + 7] , al
	ret

convertHexToAski endp
printNotification proc address: dword ; in thong bao
	push 0
	push 0
	push address
	push 0
	call MessageBox
	
	ret

printNotification endp
readByte proc byteRead: dword ; Doc so luong byte truyen vao 
	push 100
	push offset data
	call RtlZeroMemory    ; dien so 0 vao vung nho dât de reset vung nho nay
	
	push 0 
	push 0
	push dword ptr [byteRead]
	push offset data
	push dword ptr [handleInput] 
	call ReadFile ; doc so luong byte da truyen vao va ghi vao trong vung nho data
	ret

readByte endp
write proc address:dword , sizeString : dword 
	xor eax , eax 
	push 0
	push 0
	push sizeString
	push address 
	push dword ptr [handleOutput]
	call WriteFile
	
	ret

write endp
writeByte proc byteRead: dword 

	push 1
	push offset phay
	call write
	
	push 0
	push 0
	push dword ptr [byteRead]
	push offset data
	push dword ptr [handleOutput]
	call WriteFile ; ghi so byte vao trong file
	
	push 1
	push offset phay
	call write
	
	push 3
	push offset mid 
	call write
	
	call convertHexToAski
	
	
	mov eax , dword ptr [byteRead]
	add eax , dword ptr [byteRead]
	cmp eax , 4
	je isWord
	jmp isDword
isWord:
	push 0
	push 0
	push eax
	push offset by + 4
	push dword ptr [handleOutput]
	call WriteFile ; ghi so byte vao trong file
	jmp endFunc
isDword:
	push 0
	push 0
	push eax
	push offset by
	push dword ptr [handleOutput]
	call WriteFile ; ghi so byte vao trong file
	jmp endFunc
endFunc:
	push 0
	push 0
	push 1
	push offset ennter
	push dword ptr [handleOutput]
	call WriteFile ; ghi dau enter
	ret

writeByte endp
main:
	;----test
	;----end test
	;start
	;Xoa file ket qua cu
	push offset pathOutput
	call DeleteFile 
	;khoi tao cac handle de doc file va ghi file 
	push 0
	push 128 
	push 3
	push 0
	push 0
	push 80000000h
	push offset pathInput
	call CreateFile ; tao hande inout
	mov dword ptr [handleInput] , eax
	
	push 0
	push 128 
	push 4
	push 0
	push 0
	push 4
	push offset pathOutput
	call CreateFile ; tao handle output
	mov dword ptr [handleOutput] , eax
	;;
	
	push 0
	push 0
	push 60
	push dword ptr [handleInput]
	call SetFilePointer ; di chuyen den vi tri cua ifanview
	
	push 4
	call readByte  ; doc 4 byte ifenview
	
	mov edx ,  dword ptr [data]
	mov dword ptr [ifanview] , edx
	push 0
	push 0
	push dword ptr [data]
	push dword ptr [handleInput]
	call SetFilePointer ; di chye nden dau header
	;;doc chu ki
	push 4
	push offset pe
	call write 
	
	push 4 
	call readByte ; doc 4 byte dau la chu ki cua file
	push 4
	call writeByte 
	
	;;so luong section
	push 1 ; vi tri hien tai 
	push 0
	push 2
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 17
	push offset numnerOfSection ; tieu de
	call write 
	
	; doc 2 buye so luong section
	push 2 
	call readByte 
	push 2
	call writeByte 
	
	; doc magic xa dinh do dai cua image base 
	
	push 1
	push 0
	push 16
	push dword ptr [handleInput]
	call SetFilePointer  ; di chuyen den magic
	
	push 2
	call readByte 
	
	mov dx , word ptr [data]
	mov word ptr [magic] , dx	
	;doc  entry point
	push 4
	push offset ep
	call write
	
	push 1
	push 0
	push 14
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 4
	call readByte 
	
	push 4
	call writeByte  
	
	
	
	; tien hanh doc image base
	push 10
	push offset imageBase
	call write
	cmp word ptr [magic] ,  010Bh ; kiem tra xem chuong trinh la 64 bit hay 32 bit thong qua magic
	je is32Bit
	jmp is64Bit
is32Bit: ; neu la 32 bit thi imagebase se laf dword
	push 1
	push 0
	push 8
	push dword ptr [handleInput]
	call SetFilePointer ; bo 8 byte thi gom base of code va 1 truonwg nao nuwa
	push 4
	call readByte ; doc 4 buye
	call convertHexToAski
	push 4
	call writeByte 
	jmp endReadMagic
is64Bit: ; new 64 bit thi image base se laf 64 bit
	push 1
	push 0
	push 4
	push dword ptr [handleInput]
	call SetFilePointer ; di chuyen den dau image base
	
	push 1
	push 0
	push 4
	push dword ptr [handleInput]
	call SetFilePointer ; bo qua 4 byte dau de duyet 4 byte cuoi truoc
	
	push 4
	call readByte ; doc 4 byte cuoi
	push 1
	push offset phay 
	call write ; ghi dau "
	push 4
	push offset data
	call write ; ghi 4 ki tu chua conver sang hex
	call convertHexToAski ; conver va luu vao bien by	
	push 1
	push 0
	push -8
	push dword ptr [handleInput]
	call SetFilePointer ; chuyen con tro ve byte bat dau image base
	
	push 4
	call readByte ; doc not 4 byte dau
	push 4
	push offset data
	call write ; ghi 4 byte dau vao cuoi
	push 1
	push offset phay; ghi dau "
	call write 
	push  3
	push offset mid ; ghi dau = 
	call write 
	push 8
	push offset by
	call write ; ghi 4 ki tu cuoi da con ver sang hex
	call convertHexToAski ; conver 4 ki tu dau
	push 8
	push offset by
	call write ; ghi 4 ki tu dau da convert sang hex
	push 1
	push offset ennter ; ghi dau xuong dong
	call write
	jmp endReadMagic
endReadMagic:

	; doc infor table section
	push 15
	push offset sectionInfor ; ghi tieu de
	call write 
	 
	
 	push 0
 	push 0
 	push dword ptr [ifanview] 
 	push dword ptr [handleInput]
 	call SetFilePointer ; di chuyen den vi tri bat dau cua FE header
 	
 	cmp word ptr [magic] ,  010Bh
 	je iss32bit
 	jmp iss64bit
iss32bit:
	push 1
 	push 0
 	push 248
 	push dword ptr [handleInput]
 	call SetFilePointer
 	jmp loopGetSectionInfor
iss64bit :	
	push 1
 	push 0
 	push 264
 	push dword ptr [handleInput]
 	call SetFilePointer
	  ; tu fe header di chuyen den sextion table
 	
 	;vi DosStub khoong  co dinh do dai nen phai lam nhu the nay 
loopGetSectionInfor:
	call middleCompartment ; ghi ra dau ngan giua cac section
	push 1
	call readByte  ; doc 1 buye dau tien 
	
	
	
	cmp byte ptr [data] , 0
	je endGetSectionInfor ; neu byet do la 0 thi  doc xong tat ca cac sextion
	 
	 
	push 1
	push 0
	push -1
	push dword ptr [handleInput]
	call SetFilePointer  ; di chuyen lai vi tri bat dau 
	
	push 8
	call readByte ; doc 8 byte dau tien laf name cua section
	
	push 8
	push offset data 
	call write ; ghi vao trong file
	
	push 1
	push offset ennter 
	call write  ; ghi dau xuong dong
	
	push 13
	push offset virtualSize ; ghi tieu de
	call write
	
	push 4
	call readByte ; doc 4 byte la virtualSize
	
	push 4
	call writeByte  ; ghi vao file
	
	
	push 16 
	push offset virtualAddress
	call write 
	
	push 4
	call readByte  ; 4 byte virtual address
	push 4
	call writeByte  
	
	push 9
	push offset rawSize
	call write 
	
	push 4
	call readByte 
	push 4
	call writeByte ; 4 byte raw size
	
	push 12
	push offset rawAddress
	call write 
	
	push 4
	call readByte 
	push 4
	call writeByte ; 4 byte raw address
	
	push 1
	push 0 
	push 16
	push dword ptr [handleInput] ; da doc 14 byte ma moi section co 40 byte nen => bo qua 16 byte con lai 
	call SetFilePointer 
	jmp loopGetSectionInfor
endGetSectionInfor:	

	;;;;;;;;;;;;;; iat 
	push 0
	push 0
	push dword ptr [ifanview]
	push dword ptr [handleInput]
	call SetFilePointer 
	cmp word ptr [magic] ,  010Bh 
	je issss32bit 
	jmp issss64bit
issss32bit:
	push 1
	push 0
	push 128
	push dword ptr [handleInput]
	call SetFilePointer  ; di chuyen den vi tri de doc rva cua direc
	jmp okNext
issss64bit:	
	push 1
	push 0
	push 144
	push dword ptr [handleInput]
	call SetFilePointer  ; di chuyen den vi tri de doc rva cua direc
okNext:	
	push 8 
	call readByte 
	
	
	
	mov edx , dword ptr [data]
	mov dword ptr [rva] , edx
	call convertRvaToOffset ; dung ham de chuyen tu rva sang ofset
	
	mov edx , dword ptr [offsetAddress]
	mov dword ptr [offsetImport] , edx ; sau do lay duoc oggset cua importFile 
	
	push 11
	push offset iat
	call write 
	push 1
	push offset ennter
	call write
	
	
tableImport:
	mov edx , dword ptr [stt] ; lay vi tri cac rva cua tung thu vien 
	add edx , dword ptr [offsetImport] ; cong them vao trong dia chi offset cua import 
	push 0 
	push 0
	push edx
	push dword ptr [handleInput] 
	call SetFilePointer 
	
	push 4
	call readByte ; doc 4 buye la oft rva dia chi ao chua dia chi cac ham 
	
	
	mov edx , dword ptr [data]   
	mov dword ptr [ofts]  , edx   ; luu lai

	cmp dword ptr [ofts] , 0
	je endTableImport
	
	push 4
	call readByte ; tien hanh doc cac truong thong tin khac 
	
	mov edx , dword ptr [data]
	mov dword ptr [timeDateStamp]  , edx
	
	push 4
	call readByte
	mov edx , dword ptr[data]
	mov dword ptr [forwarderChain] , edx
	push 4
	call readByte
	mov edx , dword ptr [data]
	mov dword ptr [nameRva] , edx
	
	push 4
	call readByte
	mov edx , dword ptr [data] 
	mov dword ptr [iatImport] , edx
	
	
	mov edx , dword ptr [nameRva]
	mov dword ptr [rva] , edx 
	; sau khi luu laij tat ca thi convert sang dia chi offset de tien hanh lay name cua thu vien
	call convertRvaToOffset
	
	push 0 
	push 0 
	push dword ptr [offsetAddress]
	push dword ptr [handleInput]
	call SetFilePointer  ; di chuyen den dia chi chua ten cua thu vien
	
	push 100 
	push offset nameDll
	call RtlZeroMemory ; reset lai khoang khong gian luu ten thu vien 
	; sau do tien hanh lay ten bang cach duyet qua tung buye den khi byte bang 0
	mov byte ptr [index] , 0 
loopGetName:
	push 1
	call readByte ; doc tung byte 1
	cmp byte ptr [data] , 0 ; so sanh
	je endGetName
	;luu vao trong vi tri cua noi luu ten
	mov dl , byte ptr [data] 
	mov eax , dword ptr [index]
	mov byte ptr [nameDll + eax] , dl 
	inc dword ptr [index] ; sau moi vong tang index len de tro den byte luu tiep theo nameDll
	;data luon tro tang vi ham readByte se tu tang sau khi doc byte
	jmp loopGetName
endGetName:
	
	
	
	
	
	;;ghi vao trong file
	
	
	call middleCompartment 
	
	push 13 
	push offset moduleName; ghi ghi tieu de
	call write 
	
	push 100 
	push offset nameDll  ; ghi ten
	call write
	push 1
	push offset ennter 
	call write
	
	cmp word ptr [magic] ,  010Bh ; tien hanh doc cac ham trong thu vien 
	je t32bitt ; thi oft cua no chi la 4 byte 
	jmp t64bitt ; thig oft no tan 8 byte
	;;;;;
	
t32bitt:
	mov dword ptr [index] , 0
getNameok:	
	call middleCompartment
	mov edx , dword ptr [ofts]; lay gia tri ofts cua thu vien
	mov dword ptr [rva] , edx
	call convertRvaToOffset
	mov ecx , dword ptr [index]
	add ecx , dword ptr [offsetAddress]
	push 0
	push 0
	push  ecx
	push dword ptr [handleInput]
	call SetFilePointer  ; di chuyen den noi luu dia chi ao tuong doi cua cac ham trong thu vin
	push 4
	call readByte 
	push 4
	call writeByte  ; doc 4 byte 1
	cmp dword ptr [data] , 0 ; neu bang 0 thi tuc la no ket thuc
	je endGetNameok
	
	;; luc nay da co dia chi ao cua caca ham trong thu vien 
	mov edx , dword ptr [data] ; sau do tien hanh di chuyen den vi tri day 
	mov dword ptr [rva] , edx
	call convertRvaToOffset
	push 0
	push 0
	push dword ptr [offsetAddress]
	push dword ptr [handleInput]
	call SetFilePointer ; di chuyen
	
	push 2
	call readByte 
	push 2
	call writeByte  ; doc 2 buye chinh la hint cua ham  
	
	push 100
	push offset nameFunc
	call RtlZeroMemory 
	mov dword ptr [index2] , 0; sau do tien hanh doc byye 
okname:
	push 1
	call readByte 
	
	cmp byte ptr [data] , 0
	je enOkName
	
	mov dl , byte ptr [data]
	mov ecx , dword ptr [index2]
	mov byte ptr [nameFunc + ecx] , dl
	inc dword ptr [index2]
	jmp okname ; doc nhu tren 
enOkName:	
	;; 
	push 100
	push offset nameFunc
	call write  ; ghi ten 
	push 1 
	push offset ennter
	call write 
	add dword ptr [index] , 4 ; moi dia chi ao tuong doi se cach nhau 4 byte 
	jmp getNameok
endGetNameok:	
	
	;;;;;;;;
	push 6
	push offset OFTs ; ghi dia chi ao 
	call write 
	
	mov edx , dword ptr [ofts]
	mov dword ptr [data] , edx 
	push 4
	call writeByte  ; ghi dia chi ao cua thu vien 
	
	push 15
	push offset Time
	call write
	mov edx , dword ptr [timeDateStamp]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 16
	push offset ForwarderChain
	call write 
	
	mov edx , dword ptr [forwarderChain]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 10
	push offset NameRVA
	call write 
	
	mov edx , dword ptr [nameRva]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 11
	push offset fts
	call write 
	
	mov edx , dword ptr [iatImport]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	;;
	add dword ptr [stt] , 20
	jmp tableImport
t64bitt:	;64 bit thi tuong tu nhung oft cua no se 8byte nen khi duyet thi se tang index 8 byte 1
	mov dword ptr [index] , 0
getNameok2:	
	push 40
	push offset ngan
	call write
	mov edx , dword ptr [ofts]
	mov dword ptr [rva] , edx
	call convertRvaToOffset
	mov ecx , dword ptr [index]
	add ecx , dword ptr [offsetAddress]
	push 0
	push 0
	push  ecx
	push dword ptr [handleInput]
	call SetFilePointer 
	push 8
	call readByte
 
	 
	push 8
	call writeByte 
	cmp dword ptr [data] , 0
	je endGetNameok
	
	;;
	mov edx , dword ptr [data]
	mov dword ptr [rva] , edx
	call convertRvaToOffset
	push 0
	push 0
	push dword ptr [offsetAddress]
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 2
	call readByte 
	push 2
	call writeByte  
	
	push 100
	push offset nameFunc
	call RtlZeroMemory 
	mov dword ptr [index2] , 0
okname2:
	push 1
	call readByte 
	
	cmp byte ptr [data] , 0
	je enOkName2
	
	mov dl , byte ptr [data]
	mov ecx , dword ptr [index2]
	mov byte ptr [nameFunc + ecx] , dl
	inc dword ptr [index2]
	jmp okname2
enOkName2:	
	;; 
	push 100
	push offset nameFunc
	call write 
	push 1 
	push offset ennter
	call write 
	add dword ptr [index] , 8
	jmp getNameok2
endGetNameok2:	
	
	;;;;;;;;
	push 6
	push offset OFTs
	call write 
	
	mov edx , dword ptr [ofts]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 15
	push offset Time
	call write
	mov edx , dword ptr [timeDateStamp]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 16
	push offset ForwarderChain
	call write 
	
	mov edx , dword ptr [forwarderChain]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 10
	push offset NameRVA
	call write 
	
	mov edx , dword ptr [nameRva]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	
	push 11
	push offset fts
	call write 
	
	mov edx , dword ptr [iatImport]
	mov dword ptr [data] , edx 
	push 4
	call writeByte 
	;;
	add dword ptr [stt] , 20
	jmp tableImport
endTableImport:
	;; tien hanh doc export
	call middleCompartment
	push 11
	push offset eat
	call write 
	push 1
	push offset ennter
	call write 
	call middleCompartment
	push 0
	push 0
	push dword ptr [ifanview]
	push dword ptr [handleInput]
	call SetFilePointer ;
	
	cmp word ptr [magic] ,  010Bh 
	je bit32
	jmp bit64
bit32:
	push 1
	push 0
	push 120
	push dword ptr [handleInput]
	call SetFilePointer 
	jmp endbit
bit64:
	push 1
	push 0
	push 136
	push dword ptr [handleInput]
	call SetFilePointer
endbit:
	push 4
	call readByte ; doc dia chi tuong doi cua eat
	
	mov edx , dword ptr [data]
	mov dword ptr [rva] , edx
	call convertRvaToOffset
	
	push 0
	push 0
	push dword ptr [offsetAddress]
	push dword ptr [handleInput]
	call SetFilePointer ; sau do di chuyen den vi tri do va tien hanh doc lan luojt
	
	
	push 17
	push offset a1
	call write 
	push 4
	call readByte 
	push 4
	call writeByte  ; 
	
	push 15
	push offset a2
	call write
	push 4
	call readByte 
	push 4
	call writeByte
	
	push 14
	push offset a3
	call write
	push 2
	call readByte 
	push 2
	call writeByte
	
	push 14
	push offset a4
	call write
	push 2
	call readByte
	push 2
	call writeByte 
	
	push 6
	push offset a5
	call write
	push 4
	call readByte 
	push 4
	call writeByte
	
	push 6
	push offset a6
	call write
	push 4
	call readByte 
	push 4
	call writeByte
	
	
	push 19
	push offset a7
	call write
	push 4
	call readByte 
	push 4
	call writeByte
	mov edx , dword ptr [data]
	mov dword ptr [numberOfFunction] , edx
	
	push 15
	push offset a8
	call write
	push 4
	call readByte 
	push 4
	call writeByte
	mov edx , dword ptr [data]
	mov dword ptr [numberOfNames] , edx
	
	push 19
	push offset a9
	call write
	push 4
	call readByte
	push 4
	call writeByte 
	mov edx , dword ptr [data]
	mov dword ptr [addressOfFunction] , edx
	
	push 16
	push offset a10
	call write
	push 4
	call readByte
	push 4
	call writeByte
	mov edx , dword ptr [data]
	mov dword ptr [addressOfNames] , edx
	
	push 24
	push offset a11
	call write
	push 4
	call readByte
	push 4
	call writeByte
	mov edx , dword ptr [data]
	mov dword ptr [addressOfNameOrdinals] , edx
	call middleCompartment
	
	
	mov dword ptr [index] , 0
	mov dword ptr [index2] , 0
loopGetFuncEx:
	call middleCompartment
	cmp dword ptr [numberOfFunction] , 0
	je endGetInforExport
	
	mov edx , dword ptr [addressOfFunction]
	mov dword ptr [rva] , edx ; tien hanh di chuyen den rva cua function
	
	call convertRvaToOffset
	mov eax , dword ptr [offsetAddress]
	add eax , dword ptr [index]
	push 0 
	push 0 
	push eax
	push dword ptr [handleInput]
	call SetFilePointer  
	
	push 14
	push offset a12
	call write
	push 4
	call readByte 
	
	push 4
	call writeByte  ; doc 4 byte laf func rva nay luu code cua ham export
	;;
	cmp dword ptr [numberOfNames] , 0 ; do name co the it hon nen neu doc qua thi se bo qua
	je nextloopok
	;;
	mov edx , dword ptr [addressOfNameOrdinals]
	mov dword ptr [rva] , edx
	
	call convertRvaToOffset
	mov eax , dword ptr [offsetAddress]
	add eax , dword ptr [index2]
	
	push 0
	push 0
	push eax
	push dword ptr [handleInput]
	call SetFilePointer ; di chuyen toi day
	
	push 14
	push offset a13
	call write
	push 2
	call readByte 
	push 2
	call writeByte ; doc name ordinal 
	;; tuong tu nhu the se doc name rva vi so luong name ordinal vaf name nva se giong nhau 
	mov edx , dword ptr [addressOfNames]
	mov dword ptr [rva] , edx
	
	call convertRvaToOffset
	mov eax , dword ptr [offsetAddress]
	add eax , dword ptr [index]
	
	push 0
	push 0
	push eax
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 10
	push offset a14
	call write
	push 4
	call readByte 
	push 4
	call writeByte ; doc rva name
	
	mov edx , dword ptr [data]
	mov dword ptr [rva] , edx
	
	call convertRvaToOffset
	
	push 0
	push 0
	push dword ptr [offsetAddress]
	push dword ptr [handleInput]
	call SetFilePointer 
	mov dword ptr [index3] , 0 ; sau do di chuyen toi de doc name
loopGetNameEx: ; vong lap doc name
	
	push 1
	call readByte 
	cmp byte ptr [data] , 0
	je endGetNameEx
	mov dl , byte ptr [data]
	mov ecx , dword ptr [index3]
	
	mov byte ptr [nameExportFunction + ecx] , dl
	inc dword ptr [index3]
	jmp loopGetNameEx
	
	push 100 
	push offset nameExportFunction
	call RtlZeroMemory
endGetNameEx:
	push 6
	push offset a15
	call write
	push 100 
	push offset nameExportFunction ; ghi name vao 
	call write 
	push 1
	push offset ennter
	call write 	
	dec dword ptr [numberOfNames]
	
nextloopok:	
	add dword ptr [index]  , 4 ; funtion rva laf 4 byte 
	add dword ptr [index2]  , 2 ; cai nay laf do name ordinal chi co 2 byte 
	dec dword ptr [numberOfFunction]
	jmp loopGetFuncEx
	
	
	
endGetInforExport:
	
	push 0
	push 0
	push dword ptr [ifanview]
	push dword ptr [handleInput]
	call SetFilePointer 
	
	cmp dword ptr [magic] , 010Bh
	je bit3232
	jmp bit6464
bit3232:
	push 1
	push 0
	push 160
	push dword ptr [handleInput]
	call SetFilePointer 
	jmp nextRelo
bit6464:
	push 1
	push 0
	push 176
	push dword ptr [handleInput]
	call SetFilePointer 
nextRelo:
	push 4
	call readByte ; doc rva cua direc
	
	mov edx , dword ptr [data]
	mov dword ptr [rvaRelocDec] , edx
	mov dword ptr [rva] , edx
	call convertRvaToOffset
	push 0
	push 0
	push dword ptr [offsetAddress]
	push dword ptr [handleInput]
	call SetFilePointer 
	
	
	
	
getRelocTable:	
	call middleCompartment
	push 4
	call readByte 
	mov edx , dword ptr [data]
	mov dword ptr [rvaReloc] , edx
	
	cmp dword ptr [data] , 0
	je endGetRelocTable
	
	push 4
	call writeByte 
	
	push 4
	call readByte 
	mov edx , dword ptr [data]
	mov dword ptr [sizeOfBlock] , edx
	
	push 4
	call writeByte 
	call middleCompartment
loopGetItem:
	call middleCompartment
	push 2
	call readByte 
	push 2
	call writeByte
	call convertHexToAski
	cmp byte ptr [by +4] , "0"
	je isab
	cmp byte ptr [by + 4] , "1"
	je ishi
	cmp byte ptr [by +4] , "2"
	je isl
	cmp byte ptr [by +4] , "3"
	je ishil
	cmp byte ptr [by +4] , "A"
	je isdi
isab:
	push 8
	push offset absolute
	call write 
	jmp endtype
ishi:
	push 4
	push offset highbase
	call write 
	jmp endtype
isl	:
	push 3
	push offset lowbase
	call write 
	jmp endtype
ishil:
	push 7
	push offset highlow
	call write 
	jmp endtype
isdi:
	push 5
	push offset dir64
	call write 
	jmp endtype
endtype:
	cmp word ptr [data] , 0
	je  getRelocTable
	jmp loopGetItem
endGetRelocTable:
	
	
	
	
notExits: ; khong tim thay trong bat cu section naof => khong ton tai table 	
	;End process
	push 0
	call ExitProcess 
end main	
