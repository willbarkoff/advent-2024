global main

extern atoi
extern itoa
extern printf

;
; CONSTANTS
;
SYS_OPEN equ 2
SYS_CLOSE equ 3
SYS_EXIT equ 60
SYS_READ equ 0
SYS_WRITE equ 1

STDOUT equ 1

MAX_DIFF equ 3

;
; Initialised data goes here
;
SECTION .data
    filename db "input.txt", 0
    
    print_int db "%d", 0

    buffer db 4096 dup(0)
    buffer_size equ 4096

    line_buffer db 64 dup(0)
    line_buffer_size equ 64
    
    atoi_buffer db 8 dup(0)
    atoi_buffer_size equ 8

    newline db 10
    space db 32

    answer dq    0

SECTION .bss
    bytes_read resq 1
    line_buffer_length resq 1
    fd resq 1
    line_length resq 1

;
; Code goes here
;
SECTION .text

main:
    mov rbp, rsp; for correct debugging
    mov rax, SYS_OPEN
    mov rdi, filename
    mov rsi, 0 ; Read only mode
    syscall

    mov rsi, rax ; file descriptor
    mov ecx, 2

    test rsi, rsi
    je exit ; if we can't open file, exit

    mov [fd], rsi

    xor rbx, rbx ; init rbx to 0

read_loop:
    mov rax, SYS_READ
    mov rdi, [fd] ; file descriptor
    mov rsi, buffer
    mov rdx, buffer_size
    syscall

    test rax, rax ; check if EOF
    je close_file

    mov [bytes_read], rax

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    push buffer

process_loop:
    ; rcx = cursor position in buffer
    ; rbx = cursor position in line_buffer
    ; al = current character
    mov al, [buffer+rcx]
    mov [line_buffer+rbx], al
    cmp al, byte [newline]
    jz process_report ; report of length rbx is in the buffer

finish_loop:
    inc rcx
    inc rbx
    cmp rcx, [bytes_read]
    je read_loop
    jmp process_loop

; get the next report
new_report:
    xor rbx, rbx
    inc rcx
    cmp rcx, [bytes_read]
    je read_loop
    jmp process_loop


; check to see if the report is safe
process_report:
    mov [line_buffer_length], rbx

    push rcx
    push rbx
    push rax
    push rsi

    xor rcx, rcx ; char number
    xor rbx, rbx ; last number / difference
    xor rax, rax ; this number
    xor rsi, rsi ; last difference

    ; Process the first number. This is a special case because there is no previous number to compare it to.
    mov rdi, line_buffer
    call do_atoi
    mov rbx, rax

process_number:
    mov rdi, line_buffer
    call do_atoi
    sub rbx, rax
    je done_processing_report ; numbers are equal, failed.

    test rsi, rsi ; if there's no previous subtraction result, skip the sign check
    je done_sign_check

    cmp rbx, rsi ; there will be no overflow if they are the same sign
    jo done_processing_report ; difference has wrong sign, failed.

done_sign_check:
    mov rsi, rbx
    test rbx, rbx ; check if rbx is positive
    jns done_negation ; if positive, skip negation
    neg rbx ; otherwise, negate rbx

done_negation:
    ; check to make sure that we didn't jump by more than 3
    cmp rbx, MAX_DIFF
    jg done_processing_report ; if we jumped by more than 3, fail

    ; now we need to check if there's another number in the report
    cmp rcx, [line_buffer_length]
    jne process_number

    inc qword [answer]

done_processing_report:
    pop rsi
    pop rax
    pop rbx
    pop rcx
    
    xor rbx, rbx
    
    jmp new_report

; put base address in rdi and offset in rcx. Updates rcx with new offset Make sure to save registers first 
do_atoi:
    mov al, [rdi+rcx]
    cmp al, byte [space]
    jz atoi_make_call
    cmp al, byte [newline]
    jz atoi_make_call
    mov [atoi_buffer+rcx], al
    inc rcx
    inc rdi
    jmp do_atoi
    
atoi_make_call:
    mov [atoi_buffer+rcx], byte 0 ; put null-terminator at end of string
    inc rcx
    push rcx
    mov rdi, atoi_buffer
    call atoi 
    pop rcx
    ret


close_file:
    mov rax, SYS_CLOSE
    mov rdi, [fd]
    syscall
    mov rcx, 0
    
    mov rdi, print_int
    mov rsi, [answer]
    call printf
    
    mov rcx, 0

; exit with exit code in rcx
exit:
    mov rax, SYS_EXIT
    mov rdi, rcx
    syscall
