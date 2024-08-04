%macro ISR_ERR_CODE 1
    global isr_%1:
    isr_%1:
        CLI
        PUSH LONG 0
        JMP isr_common_stub

%endmacro


; if writing for 64-bit, use iretq instead
%macro ISR_NO_ERR_CODE 1
    global isr_%1:
    isr_%1:
        CLI
        PUSH LONG 0
        PUSH LONG %1
        JMP isr_common_stub
%endmacro

ISR_ERR_CODE    8
ISR_ERR_CODE    10
ISR_ERR_CODE    11
ISR_ERR_CODE    12
ISR_ERR_CODE    13
ISR_ERR_CODE    14
ISR_ERR_CODE    17
ISR_ERR_CODE    30

ISR_NO_ERR_CODE 0
ISR_NO_ERR_CODE 1
ISR_NO_ERR_CODE 2
ISR_NO_ERR_CODE 3
ISR_NO_ERR_CODE 4
ISR_NO_ERR_CODE 5
ISR_NO_ERR_CODE 6
ISR_NO_ERR_CODE 7
ISR_NO_ERR_CODE 9
ISR_NO_ERR_CODE 15
ISR_NO_ERR_CODE 16
ISR_NO_ERR_CODE 18
ISR_NO_ERR_CODE 19
ISR_NO_ERR_CODE 20
ISR_NO_ERR_CODE 21
ISR_NO_ERR_CODE 22
ISR_NO_ERR_CODE 23
ISR_NO_ERR_CODE 24
ISR_NO_ERR_CODE 25
ISR_NO_ERR_CODE 26
ISR_NO_ERR_CODE 27
ISR_NO_ERR_CODE 28
ISR_NO_ERR_CODE 29
ISR_NO_ERR_CODE 31

ISR_NO_ERR_CODE 128
ISR_NO_ERR_CODE 177

%macro IRQ 2
    global irq_%1:
    irq_%1:
        CLI
        PUSH LONG 0
        PUSH LONG %2
        JMP irq_common_stub
%endmacro

IRQ     0,     32
IRQ     1,     33
IRQ     2,     34
IRQ     3,     35
IRQ     4,     36
IRQ     5,     37
IRQ     6,     38
IRQ     7,     39
IRQ     8,     40
IRQ     9,     41
IRQ     10,    42
IRQ     11,    43
IRQ     12,    44
IRQ     13,    45
IRQ     14,    46
IRQ     15,    47



extern isr_handler
isr_common_stub:
    pusha
    mov eax, ds
    PUSH eax
    MOV eax, cr2
    PUSH eax

    MOV ax, 0x10
    MOV ds, ax
    MOV es, ax
    MOV fs, ax
    MOV gs, ax

    PUSH esp
    CALL isr_handler

    ADD esp, 8
    pop ebx
    
    MOV ds, bx
    MOV es, bx
    MOV fs, bx
    MOV gs, bx
    
    POPA
    ADD esp, 8
    STI
    IRET
    


extern irq_handler
irq_common_stub:
    pusha
    mov eax, ds
    PUSH eax
    MOV eax, cr2
    PUSH eax

    MOV ax, 0x10
    MOV ds, ax
    MOV es, ax
    MOV fs, ax
    MOV gs, ax

    PUSH esp
    CALL irq_handler

    ADD esp, 8
    pop ebx
    
    MOV ds, bx
    MOV es, bx
    MOV fs, bx
    MOV gs, bx
    
    POPA
    ADD esp, 8
    STI
    IRET
    
