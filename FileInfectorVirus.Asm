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
	path db "C:\Users\LuongTD\Desktop\RadASM-2.2.2.4-FullPackage\Masm\Projects\FileInfectorVius\test" , 0
	handle dd ?
	wfd WIN32_FIND_DATA <>
.code	
	push offset wfd
	push offset path
	call FindFirstFile 
