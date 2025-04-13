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
    msg1 db "Write an x86/64 ALP to accept 5 hexadecimal numbers from user and store them in an array and display the count of positive number and negative number", 10, \
        "Name - Abhishek Bachchis", 10, "Roll No - 7205", 10
    msg1len equ $-msg1

    msg2 db "Enter 5 64-bit hexadecimal numbers (0-9, A-F only): ", 10
    msg2len equ $-msg2

    msg3 db "the count of positive number are: ", 10
    msg3len equ $-msg3

    msg4 db "the count of negative number are:", 10
    msg4len equ $-msg4
    pcount db 0
    ncount db 0

    newline db 10

section .bss
    asciinum resb 17    ; Buffer for user input (16 characters + 1 for null terminator)
    hexnum resq 5       ; Array to store 5 64-bit hexadecimal numbers
section .code
global _start
_start:
    ; Display initial message
    io 1, 1, msg1, msg1len
    io 1, 1, msg2, msg2len

    ; Input 5 hexadecimal numbers
    mov rcx, 5          ; Loop counter for 5 inputs
    mov rsi, hexnum     ; Address to store the converted numbers
next1:
    push rsi            ; Save registers
    push rcx

    io 0, 0, asciinum, 17   ; Read input from user (up to 16 characters)
    ; Convert ASCII to hexadecimal
    call ascii_hex64

    ; Store the converted number
    pop rcx
    pop rsi
    mov [rsi], rbx
    add rsi, 8          ; Move to the next storage slot
    loop next1          ; Repeat for 5 numbers

    ; Count positive and negative numbers
    mov rcx, 5
    mov rsi, hexnum
back:
    mov rax, [rsi]
    bt rax, 63
    jc next2
    inc byte[pcount]
    jmp skip
next2:
    inc byte[ncount]
skip:
    add rsi, 8
    loop back
    
    ; Display the count of positive and negative numbers
    io 1, 1, msg3, msg3len
    mov bl, [pcount]
    call hex_ascii8

    io 1, 1, msg4, msg4len
    mov bl, [ncount]
    call hex_ascii8

    exit                ; Exit the program

; Function to convert hexadecimal to ASCII and print
hex_ascii8:
    mov rsi, asciinum   ; Address of output buffer
    mov rcx, 2          ; Loop for 2 characters to convert in hexadecimal

next4:
    rol bl, 4           ; Get the most significant nibble
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

ascii_hex64:
    mov rsi, asciinum   ; Address of input buffer
    mov rbx, 0          ; Clear rbx to store the number
    mov rcx, 16         ; Loop for 16 characters
next3:
    rol rbx, 4          ; Make space for the next nibble
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
