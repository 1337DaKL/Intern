.386
.model flat, stdcall  ;32 bit memory model
.stack 100h
option casemap :none  ;case sensitive
include user32.inc
include kernel32.inc
include IO.asm
; Directives for the linker to link libraries
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
.data
	InputData db 1000 dup (0)
	OutputData db 1000 dup (0)
	numberOne db "12345678" , 0 ;so thu nhat
	numberTwo db "100000000000000000000000" , 0 ; so thu hai
	lenOne dd ?
	lenTwo dd ?
	lenMax dd ?
	nho dd 0
	ketQua db 100 dup (0) ; mang luu ket qua 
.code
start:
	;Test
	;----
	;----
	;End test
	
	;push offset InputData
	;call ReadFileInput
	mov eax, 0
	mov edx, 0
	mov ecx, 0
	; Bat dau code tu day 
	;--------------------------------------
	
	;Tinh do dai chuoi thu nhat
	;------------------------
	mov edi , offset numberOne
	xor ecx , ecx; dem do dai cua string, khoi tao = 0
tinhLenOne:
	mov dl , byte ptr [edi + ecx]; lay gia tri vi tri dau tien 
	cmp dl , 00000000b ;so sanh ki tu ket thuc chuoi
	je saveLenOne; neu bang thi nhay toi ham luu 
	inc ecx
	jmp tinhLenOne
saveLenOne:
	mov dword ptr [lenOne] , ecx ; luu gia tri len cua chuoi thu nhat tu thanh ghi ecx vao trong memory chua lenOne
	;-----------------------------------
	;Ket thuc tinh do dai chuoi thu nhat
	
	;Tinh do dai chuoi thu 2
	;-----------------------
	xor edi , edi 
	xor ecx , ecx 
	mov edi , offset numberTwo 
tinhLenTwo:
	mov dl , byte ptr [edi + ecx]
	cmp dl , 00000000b
	je saveLenTwo
	inc ecx 
	jmp tinhLenTwo
saveLenTwo:
	mov dword ptr [lenTwo] , ecx
	;-----------------------
	;Ket thuc tinh do dai chuoi thu 2
	
	
	;tim len max 
	;-------------
	xor eax , eax ; reset thanh ghi ax
	xor edx , edx ; reset thanh ghi dx
	mov eax , lenOne ; gan gia tri lenOne cho ax
	mov edx , lenTwo  ; gan gia tri lenTwo cho dx
	cmp eax , edx ; so sanh ax va dx
	jl saveMax  ; neu ax nho hon dx  thi luu
	mov edx , eax ; neu nguoc lai thi thay dx la ax
	jmp saveMax ; sau do luu
saveMax:
	mov dword ptr [lenMax] , edx ; luu vao bien lenMax
	;-------------
	;Ket thuc tim len max
	
	;Tinh tong hai so lom
	;-------------------
	xor eax , eax 
	xor ebx , ebx 
	xor ecx , ecx 
	xor edx , edx 
	xor esi , esi 
	xor edi , edi
	
	mov esi , offset numberOne ;lay vi tri cua chuoi thu nhat
	mov edi , offset numberTwo ;lay vi tri cua chuoi thu hai
	mov ebx , lenOne ; lay do dai chuoi thu nhat
	mov ecx , lenTwo ;lay do dai chuoi thu hai
	
	
	;-------------------
	;End tinh tong so lon 
	
	
	
	
	
	
	
	
	
	
	;--------------------------------------
	;push edx
	;call WriteFileOutput
	;push 0
	;Call ExitProcess
end start
