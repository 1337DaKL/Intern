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
	InputData db  "C:\Users\LuongTD\Downloads\TinhTongHaiSo\Input.txt" , 0
	OutputData db "C:\Users\LuongTD\Downloads\TinhTongHaiSo\Output.txt" , 0
	data db 512  dup(0);du lieu se duoc luu vao day
	real dd ?
	numberOne db 512  dup (0)  ;so thu nhat
	numberTwo db 512  dup(0); so thu hai
	lenOne dd ?
	lenTwo dd ?
	lenMax dd ?
	nho db 0
	ketQua db 512  dup (0) ; mang luu ket qua 
	result db 512  dup (0);luu ket qua nhung nguoc vi khi luu trong bien ketQua bi nguoc
	lenResult dd ? ; do dai cua ket qua
	resultSave db 512  dup(0) 
.code
start:
	;Test
	;----
	;----
	;End test
	;Doc data tu file
	;----------------
	;mo file
	push 0
	push 80h ;file atrribute normal
	push 3; open exitsting
	push 0
	push 0 ; share read and write
	push 10000000h ; read and write
	push offset InputData
	call CreateFile
	;doc noi dung
	push 0
	push offset real
	push 1000
	push offset data
	push eax
	call ReadFile
	
	;; tach so thu nhat
	call resetRegister
	mov ecx , 0
	mov ebx , 0
	
_loopTachSoThuNhat:
	cmp byte ptr [data + ecx] , 20h
	je TachSoThuHai
	mov al , byte ptr [data + ecx] 
	mov byte ptr [numberOne + ecx] , al
	inc ecx 
	jmp _loopTachSoThuNhat
TachSoThuHai:
	mov byte ptr [numberOne + ecx] , 0
	inc ecx
	jmp _loopTachSoThuHai
_loopTachSoThuHai:
	cmp ecx , dword ptr [real]
	je main
	mov al , byte ptr [data + ecx]
	mov byte ptr [numberTwo + ebx] , al
	inc ecx 
	inc ebx
	jmp _loopTachSoThuHai
main:
	mov byte ptr [numberTwo + ebx] , 0
	;----------------
	;End doc data tu file
	call resetRegister
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

	;Tinh tong so lon
	;---------------
	call resetRegister
	xor esi , esi 
	xor edi , edi
	
	mov esi , offset numberOne ;lay vi tri cua chuoi thu nhat
	mov edi , offset numberTwo ;lay vi tri cua chuoi thu hai
	mov ebx , lenOne ; lay do dai chuoi thu nhat
	mov ecx , lenTwo ;lay do dai chuoi thu hai
	mov eax , lenMax
	add esi , ebx 
	add edi , ecx 
	cmp eax , ebx 
	je TH1
	jmp TH2
TH1:;truong hop so 1 lon hon so 2
	xor eax , eax 
	xor ebx , ebx 
	xor ecx , ecx 
	xor edx , edx 
	mov ecx , 0 ;bien dem ki tu truyen vao bien ket qua
_loop1:
	cmp ecx , lenTwo ; so sanh voi do dai cua chuoi ngan hon
	je next ; neu bang thi ket thuc cong bth
	mov al , byte ptr [esi - 1h] ; lay ki tu cuoi cung chuoi thu nhat
	mov dl , byte ptr [edi - 1h] ; lay ki tu cuoi cung chu thu 2
	sub al , '0'
	sub dl , '0'
	add al , dl  ; cong vao voi nhau
	add al , nho ; cong them bit nho
	mov dl , 10 ; 
	xor ah , ah; truoc khi chia reset lai thanh ghi ah , thanh ghi ah se luu phan du , con thanh ghi al se luu phan chia het
	div dl ; chia al cho dl
	add ah , '0' ; cong them de chuyen thanh ki tu 
	mov byte ptr [ketQua + ecx] , ah ; luu vao ket qua
	mov byte ptr [nho] , al ; ghi thanh bit nho
	inc ecx ; cong them
	dec esi ; tru di 
	dec edi
	jmp _loop1
next: ; tuong tu nhu the nhung thay vi cong ca 2 thi chi can cong nho voi chuoi thu nhat thoi
	cmp ecx , lenOne
	je endTinhTong
	mov al , byte ptr [esi - 1h]
	sub al , '0'
	add al , nho
	mov dl , 10
	xor ah , ah
	div dl
	add ah , '0'
	mov byte ptr [ketQua + ecx ] , ah
	mov byte ptr [nho] , al
	inc ecx 
	dec esi
	jmp next
endTinhTong: ; truong hop nho van con thi van cong vao trong chuoi 
	cmp nho , 1
	jne tinhTong
	mov byte ptr [ketQua + ecx] , '1'
	jmp tinhTong
TH2: ;Truong hop so 2 lon hon so 1 tuong tu nhu truong hop 1 thoi
	call resetRegister
	
	mov ecx , 0
_loop2:
	cmp ecx , lenOne
	je next2
	mov al , byte ptr [esi - 1h]
	mov dl , byte ptr [edi - 1h]
	sub al , '0'
	sub dl , '0'
	add al , dl
	add al , nho
	mov dl , 10
	xor ah , ah
	div dl
	add ah, '0'
	mov byte ptr [ketQua + ecx ] , ah
	mov byte ptr [nho] , al
	inc ecx
	dec esi
	dec edi
	jmp _loop2
next2:
	cmp ecx , lenTwo
	je endTinhTong2
	mov al , byte ptr[edi - 1h]
	sub al , '0'
	add al , nho
	mov dl , 10
	xor ah , ah
	div dl
	add ah , '0'
	mov byte ptr [ketQua + ecx] , ah
	mov byte ptr [nho] , al
	inc ecx
	dec edi
	jmp next2
endTinhTong2:
	cmp nho , 1
	jne tinhTong
	mov byte ptr [ketQua + ecx] , '1'
	jmp tinhTong
	;-------------------
	;End tinh tong so lon 
tinhTong:
	;TInh lai do dai cua ket qua 
	;-------------------------
	cmp nho , 1 ; xem nho con khong neu con thi can phai cong them 1
	mov dword ptr [lenResult] , 0
	jne reverseResult
	mov dword ptr [lenResult] , 1
	jmp reverseResult
reverseResult:
	call resetRegister
	mov eax , lenResult ; sau do cong them gia tri cua len max
	mov edx , lenMax
	add eax , edx
	mov dword ptr [lenResult] , eax ; luu do dai cua ket qua vao
	;-------------------------
	;End tinh lai do dai cua ket qua 
	
	;Lat nguoc lai
	;------------
	call resetRegister ; reset
	mov ecx , 0h
_loopReverse:
	cmp ecx , lenResult ; lap tung byte cua bien do dai
	je WriteFileFunc
	mov ebx , lenResult
	sub ebx , ecx
	mov al , byte ptr [ketQua + ecx] ; bien dau cau ketQua se duoc dat vao vi tri cuoi cua result
	mov byte ptr [result + ebx  - 1h] , al
	inc ecx
	jmp _loopReverse
	;------------
	;End lat nguoc lai
WriteFileFunc:
	;Xoa cac so 0 o dau
	;----------------------
	call resetRegister
	mov ecx , 0
	mov ebx , 0
_loopDeleteZeno: ; lap qua result neu la ki tu 0 thi bo qua
	cmp byte ptr [result + ecx] , '0'
	jne saveInFile
	inc ecx
	jmp _loopDeleteZeno
saveInFile:
; sau do luu lai vao mot bien moi
	cmp ecx , lenResult
	je save
	mov dl , byte ptr [result + ecx]
	mov byte ptr [resultSave + ebx], dl  
	inc ebx 
	inc ecx
	jmp saveInFile
save:
	mov ebx , lenResult
	mov byte ptr [resultSave + ebx ] , 0 ; them /0 de cho biet dau ket thuc cua 1 string
	;----------------------
	;End xoa cac so 0 o dau
	
	;Luu vao file
	;------------
	;xoa file cu
	push offset OutputData
	call DeleteFile
	;mo file
	call resetRegister
	push 0
	push 80h ;file atrribute normal
	push 4; open alway
	push 0
	push 0 ; share read and write
	push 10000000h ; read and write
	push offset OutputData
	call CreateFile
	;ghi vao file
	push 0
	push offset real
	push dword ptr [lenResult]
	push offset resultSave
	push eax
	call WriteFile
	;-----------
	;End luu vao file
	;--------------------------------------
	push 0
	Call ExitProcess
	
;Day la doan chua cac ham function
;-------------------------------
resetRegister:
	xor eax , eax 
	xor ebx , ebx
	xor ecx , ecx
	xor edx , edx
	ret
;---------------------------------
;End cac ham fuction
end start
