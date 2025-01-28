%macro io 4
	mov rax,%1
	mov rdi,%2
	mov rsi,%3
	mov rdx,%4
	syscall
%endmacro
%macro exit 0
	mov rax,60
	mov rdi,0
	syscall
%endmacro
section .data
	msg1 db "write an X86/64 ALP to accept a string and to display its length",10,'Name:-Abhishek Bachchis',10,'roll:-7205',10
	msg1len equ $-msg1 
	msg2 db "enter the string",10
	msg2len equ $-msg2
	msg3 db "the strlen without loop",10
	msg3len equ $-msg3
	msg4 db "the strlen with loop",10
	msg4len equ $-msg4
	strlen db 0
	newline db 10
section .bss
	str1 resb 20
	asciinum resb 2
section .code
global _start
_start:
	io 1,1,msg1,msg1len
	io 1,1,msg2,msg2len
	io 0,0,str1,20
	dec rax
	mov rbx,rax
	io 1,1,msg3,msg3len
	call hex_ascii8
	
mov rsi,str1
next1:
	mov al,[rsi]
	cmp al,10
	je skip
	inc byte[strlen]
	inc rsi
	loop next1
skip:
	io 1,1,msg4,msg4len
	mov bl,[strlen]
	call hex_ascii8
exit

hex_ascii8:
    mov rsi, asciinum   ; Address of output buffer
    mov rcx, 2         ; Loop for 2  characters
next4:
    rol bl, 4          ; Get the most significant nibble
    mov al, bl          ; Isolate the nibble
    and al, 0Fh         ; Mask the lower 4 bits
    cmp al, 9
    jbe add30h          ; Convert to '0'-'9'
    add al, 7h          ; Convert to 'A'-'F'
add30h:
    add al, 30h         ; Convert to ASCII
    mov [rsi], al       ; Store in output buffer
    inc rsi             ; Move to next character
    loop next4
    io 1, 1, asciinum, 2 ; Print the converted number
    io 1, 1, newline, 1 ; Print newline
    ret
	
