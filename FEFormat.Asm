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
	pathInput db "D:\Code\Homework Intern\PE Fomat\PE Fomat.exe",0
	pathOutput db "D:\Code\Homework Intern\PE Fomat\Results.txt" , 0	    
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
	RawAddress db "RawAddress: ", 0
	RawSize db "RawSize: ", 0
	reloc db "Reloc Table: " , 0
	iat db "IAT Table: ", 0
	eat db "EAT Table: ", 0 
	mid db " = " , 0
	phay db 22h ;dau "
	magic dw ?
.code
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
	push 1
	push 0
	push 2
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 17
	push offset numnerOfSection
	call write 
	
	push 2 
	call readByte 
	push 2
	call writeByte 
	
	; doc magic xa dinh do dai cua image base 
	
	push 1
	push 0
	push 16
	push dword ptr [handleInput]
	call SetFilePointer 
	
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
	
	
	
	
	push 10
	push offset imageBase
	call write
	cmp word ptr [magic] ,  010Bh
	je is32Bit
	jmp is64Bit
is32Bit:
	push 1
	push 0
	push 8
	push dword ptr [handleInput]
	call SetFilePointer 
	push 4
	call readByte 
	call convertHexToAski
	push 4
	call writeByte 
	jmp endReadMagic
is64Bit:
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
	push 15
	push offset sectionInfor
	call write 
	 
	
 	push 0
 	push 0
 	push 448 
 	push dword ptr [handleInput]
 	call SetFilePointer 
 	
loopGetSectionInfor:
	push 1
	call readByte 
	cmp byte ptr [data] , 0
	je endGetSectionInfor
	push 1
	push 0
	push -1
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 8
	call readByte 
	
	push offset data
	call printNotification 
	
	jmp loopGetSectionInfor
	
endGetSectionInfor:	
	;End process
	push 0
	call ExitProcess 
end main
