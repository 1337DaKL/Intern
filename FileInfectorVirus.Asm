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
	path db "D:\document\Buoi2" , 0
	handle dd ?
	wfd WIN32_FIND_DATA <>
.code
main:
	push offset wfd
	push offset path
	call FindFirstFile 
	mov dword ptr [handle], eax
loopFile:
	push offset wfd
	push dword ptr [handle]
	call FindNextFile
	cmp eax , 0
	je endLoopFile 
	jmp loopFile
endLoopFile:
end main
