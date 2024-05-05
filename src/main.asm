org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ;NASM Macro for newline char

start:
    jmp main


; Prints a string to the screen
;
; Parameters :
;   - ds:si points to string
;
puts:
    push si
    push ax

.loop:
    lodsb           ; loads next char into al    
    ; Takes char from al to write
    mov ah, 0x0e    ; Call bios INT
    mov bh, 0       ; Sets page number to 0
    int 0x10

    or al, al       ; checks if al register is null
    jnz .loop       ; jumps if al is not 0
    ; Ignore BL foreground pixel (only for graphics mode)

done:
    pop ax
    pop si
    ret


main:
    ; set up data segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; set up stack
    mov ss, ax      ; Sets stack segment to 0
    mov sp, 0x7C00  ; Sets stack pointer to beginning of this file.


    mov si, str_hello
    call puts

    hlt

.halt:
    jmp .halt


str_hello: db 'Hello World!', ENDL, 0



times 510-($-$$) db 0
dw 0xAA55