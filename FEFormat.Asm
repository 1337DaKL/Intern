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
	pathInput db "C:\Users\LuongTD\Downloads\FE File\Bai2.exe",0
	pathOutput db "C:\Users\LuongTD\Downloads\FE File\Results.txt" , 0	    
	handleInput dd ?
	handleOutput dd ?
	ifanew db 4 dup (0)
	data db 1000 dup (0)
.code
printNotification proc address: dword
	push 0
	push 0
	push address
	push 0
	call MessageBox
	
	ret

printNotification endp
main:
	;start
	push 0
	push 128 
	push 3
	push 0
	push 0
	push 80000000h
	push offset pathInput
	call CreateFile 
	mov dword ptr [handleInput] , eax
	
	push 0
	push 128 
	push 3
	push 0
	push 0
	push 4
	push offset pathOutput
	call CreateFile 
	mov dword ptr [handleOutput] , eax
	
	push 0
	push 0
	push 60
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 0 
	push 0
	push 4
	push offset ifanew
	push dword ptr [handleInput] 
	call ReadFile 
	
	mov edx , dword ptr [ifanew]
	
	
	
	push 0
	push 0
	push edx
	push dword ptr [handleInput]
	call SetFilePointer 
	
	
	
	push 0 
	push 0
	push 4
	push offset data
	push dword ptr [handleInput]
	call ReadFile
	
	
	;Write File
	
	push 0
	push 0
	push 4
	push offset data 
	push dword ptr [handleOutput]
	call WriteFile 
	
	push 1
	push 0
	push 0
	push dword ptr [handleInput]
	call SetFilePointer 
	
	push 0 
	push 0
	push 2
	push offset data
	push dword ptr [handleInput]
	call ReadFile
	
	push 0
	push 0
	push 2
	push offset data 
	push dword ptr [handleOutput]
	call WriteFile
	;End process
	push 0
	call ExitProcess 
end main
