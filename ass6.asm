%macro io 4
    mov rax,%1          ; System call number (1 for write, 0 for read)
    mov rdi,%2          ; File descriptor (1 for stdout, 0 for stdin)
    mov rsi,%3          ; Buffer address
    mov rdx,%4          ; Buffer size
    syscall             ; Invoke system call
%endmacro

%macro exit 0
    mov rax,60          ; System call number for exit
    mov rdi,0           ; Exit status code (0 for success)
    syscall             ; Invoke system call
%endmacro
section .data
    msg1 db "Write an x86/64 ALP to perform non-overlapped block transfer without string specific instruction.Block containing data can be defined in the data segment ",10, \
        'Name - Abhishek Bachchis', 10, 'Roll No - 7205', 10,'date of performance:25-03-25',10
    msg1len equ $-msg1

	msg2 db "menu:",10,"1.non-overlapping block transfer without string specific instruction",10,"2.non-overlapping block transfer with string specific instruction ",10
	msg2len equ $-msg2
	msg3 db "source block before transfer:",10
	msg3len equ $-msg3
	msg4 db "destination block before transfer:",10
	msg4len equ $-msg4
	msg5 db "source block after transfer:",10
	msg5len equ $-msg5
	msg6 db "destination block after transfer:",10
	msg6len equ $-msg6
	src dq  1,2,3,4,5
	dest dq 0,0,0,0,0
	space db 20h
	newline db 10
section .bss
	asciinum resb 16
	choise resb 2
section .code
global _start
_start:
	io 1,1,msg1,msg1len
	io 1,1,msg2,msg2len
	io 0,0,choise,2
case1:
	cmp byte[choise],"1"
	jne case2
	call NOWS
	jmp case3
case2:
	cmp byte[choise],"2"
	jne case3
	call NOS
	jmp case3
case3:
	exit
NOWS:
	mov rsi,src
	io 1,1,msg3,msg3len
	mov rsi,src
	call dis_block
	io 1,1,msg4,msg4len
	mov rsi,dest
	call dis_block

	mov rsi,src
	mov rdi,dest
	mov rcx,5
back1:
	mov rax,[rsi]
	mov [rdi],rax
	add rsi,8
	add rdi,8
	loop back1
	
	mov rsi,src
	io 1,1,msg5,msg5len
	mov rsi,src
	call dis_block
	mov rdi,dest
	io 1,1,msg6,msg6len
	mov rsi,dest
	call dis_block
ret

NOS:
	mov rsi,src
	io 1,1,msg3,msg3len
	mov rsi,src
	call dis_block
	io 1,1,msg4,msg4len
	mov rsi,dest
	call dis_block
	cld
	mov rsi,src
	mov rdi,dest
	mov rcx,5
	rep movsq
	mov rsi,src
	io 1,1,msg5,msg5len
	mov rsi,src
	call dis_block
	mov rdi,dest
	io 1,1,msg6,msg6len
	mov rsi,dest
	call dis_block
	ret
dis_block:
	
	mov rcx,5
back:
	mov rbx,rsi
	push rcx
	push rsi
	call hex_ascii64
	pop rsi
	mov rbx,[rsi]
	push rsi
	call hex_ascii64
	io 1,1,newline,1
	pop rsi
	pop rcx
	add rsi,8
	loop back
	ret
hex_ascii64:
    mov rsi, asciinum   ; Address of output buffer
    mov rcx, 16        ; Loop for 2 characters to convert in hexadecimal

next4:
    rol rbx, 4          ; Get the most significant nibble
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
    io 1, 1, asciinum, 16 ; Print the converted number
    io 1, 1, space, 1 ; Print newline
    ret
