org 0x7C00
bits 16


main:
    hlt

.halt:
    jmp .halt

dw 0xAA55