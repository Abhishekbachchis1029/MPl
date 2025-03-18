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
    msg1 db "Write an x86/64 ALP to convert a 4 digit hex to equivalent 5-digit BCD and 5-digit BCD number to 4 digit hexadecimal number 	",10, \
        'Name - Abhishek Bachchis', 10, 'Roll No - 7205', 10,'date of performance:18-03-25',10
    msg1len equ $-msg1

	msg6 db "menu:",10,"1.Hex_to_BCD conversion",10,"2. BCD_to_Hex conversion",10
	msg6len equ $-msg6

    msg2 db "enter a 16-bit hexadecimal number ", 10
    msg2len equ $-msg2
	
	msg5 db "enter a 16 bit BCD number:",10
	msg5len equ $-msg5

    msg3 db "the BCD conversion of the number= ", 10
    msg3len equ $-msg3

    msg4 db "the hexadecimal conversion of BCD=", 10
	msg4len equ $-msg4
    newline db 10
section .bss
	choice resb 2
	hexnum resb 5
	Bcdnum resb 6
	asciinum resb 4
section .code
global _start
_start:
	io 1,1,msg6,msg6len
	io 0,0,choice,2
	
case1:
	cmp byte[choice],"1"
	
	jne case2
	call hex_bcd
	jmp exit1
case2:
	cmp byte[choice],"2"
	jne exit1
	call bcd_hex
exit1:
	exit

hex_bcd:
		io 1,1,msg2,msg2len
		io 0,0,hexnum,5
		call ascii_hex16
		mov ax,bx
		mov rcx,5
		mov bx,0AH
		back1:
			mov rdx,0
			div bx
			push dx
			loop back1
		mov rsi,Bcdnum
		mov rcx,5
		back2:
			mov rdx,0
			pop dx
			add dl,30H
			mov [rsi],dl
			inc rsi
			loop back2
		io 1,1,msg3,msg3len
		io 1,1,Bcdnum,5
ret

bcd_hex:
		io 1,1,msg5,msg5len
		io 0,0,Bcdnum,6
		mov rsi,Bcdnum
		mov rax,0
		mov bl,0AH
		mov rcx,5
	back3:
		mul bl
		mov rdx,0
		mov dl,[rsi]
		sub dl,30H
		add ax,dx
		inc rsi
		loop back3
	mov bx,ax
	call hex_ascii16
ret
hex_ascii16:
    mov rsi, asciinum   ; Address of output buffer
    mov rcx, 4         ; Loop for 2 characters to convert in hexadecimal

next4:
    rol bx, 4          ; Get the most significant nibble
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
    io 1, 1, asciinum, 4 ; Print the converted number
    io 1, 1, newline, 1 ; Print newline
    ret

ascii_hex16:
    mov rsi, hexnum   ; Address of input buffer
    mov rbx, 0          ; Clear rbx to store the number
    mov rcx, 4         ; Loop for 16 characters
next3:
    rol bx, 4          ; Make space for the next nibble
    mov al, [rsi]       ; Load a character
    cmp al, '9'
    jbe sub30h          ; Convert '0'-'9'
    sub al, 7h          ; Adjust 'A'-'F'
sub30h:
    sub al, 30h         ; Convert ASCII to numeric value
    add bl, al          ; Add to rbx
    inc rsi             ; Move to next character
    loop next3
    ret

		
