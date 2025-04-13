%macro io 4
    mov rax,%1          ; System call number (1 for write, 0 for read)
    mov rdi,%2          ; File descriptor (1 for stdout, 0 for stdin)
    mov rsi,%3          ; Buffer address
    mov rdx,%4          ; Buffer size
    syscall             ; Invoke system call
%endmacro

%macro exit 0
    mov rax,60
    xor rdi, rdi
    syscall
%endmacro

section .data
    msg1 db "Write an x86/64 ALP to perform non-overlapped block transfer without string specific instruction.",10,\
        "Block containing data can be defined in the data segment ",10,\
        'Name - Abhishek Bachchis', 10, 'Roll No - 7205', 10,'date of performance:25-03-25',10
    msg1len equ $-msg1

    msg2 db "menu:",10,"1.non-overlapping block transfer without string specific instruction",10,\
            "2.non-overlapping block transfer with string specific instruction",10
    msg2len equ $-msg2

    msg3 db "source block before transfer:",10
    msg3len equ $-msg3

    msg4 db "destination block before transfer:",10
    msg4len equ $-msg4

    msg5 db "source block after transfer:",10
    msg5len equ $-msg5

    msg6 db "destination block after transfer:",10
    msg6len equ $-msg6

    space db 20h
    newline db 10

section .bss
    asciinum resb 16

section .data
    src dq 1,2,3,4,5
    dest dq 0,0,0,0,0

section .text
global _start

_start:
    io 1,1,msg1,msg1len
    io 1,1,msg2,msg2len

    ; --------- Case 1: No string-specific instruction ----------
    call NOWS

    ; Reset dest
    mov rcx, 5
    mov rdi, dest
    xor rax, rax
.zero_dest:
    mov [rdi], rax
    add rdi, 8
    loop .zero_dest

    ; --------- Case 2: With string-specific instruction ----------
    call NOS

    exit

; ========== Case 1: No String-Specific Instruction ==========
NOWS:
    mov rsi, src
    io 1,1,msg3,msg3len
    call dis_block

    mov rsi, dest
    io 1,1,msg4,msg4len
    call dis_block

    ; Transfer block (manual)
    mov rsi, src
    mov rdi, dest
    mov rcx, 5
.transfer_loop:
    mov rax, [rsi]
    mov [rdi], rax
    add rsi, 8
    add rdi, 8
    loop .transfer_loop

    mov rsi, src
    io 1,1,msg5,msg5len
    call dis_block

    mov rsi, dest
    io 1,1,msg6,msg6len
    call dis_block

    ret

; ========== Case 2: With String-Specific Instruction ==========
NOS:
    mov rsi, src
    io 1,1,msg3,msg3len
    call dis_block

    mov rsi, dest
    io 1,1,msg4,msg4len
    call dis_block

    cld
    mov rsi, src
    mov rdi, dest
    mov rcx, 5
    rep movsq

    mov rsi, src
    io 1,1,msg5,msg5len
    call dis_block

    mov rsi, dest
    io 1,1,msg6,msg6len
    call dis_block

    ret

; ========== Display Block (hex) ==========
dis_block:
    mov rcx, 5
.next:
    mov rbx, [rsi]
    push rcx
    push rsi
    call hex_ascii64
    pop rsi
    add rsi, 8
    pop rcx
    loop .next
    ret

; ========== Print 64-bit Hex ==========
hex_ascii64:
    mov rsi, asciinum
    mov rcx, 16
.next_nibble:
    rol rbx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 9
    jbe .add30
    add al, 7
.add30:
    add al, 30h
    mov [rsi], al
    inc rsi
    loop .next_nibble

    io 1, 1, asciinum, 16
    io 1, 1, space, 1
    io 1, 1, newline, 1
    ret
