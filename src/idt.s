global idt_flush
idt_flush:
    MOV eax, [esp+4]
    LIDT [eax]
    STI
    RET

%macro isr_err_stub 1
isr_stub_%+%1:
    call exception_handler
    iret 
%endmacro
; if writing for 64-bit, use iretq instead
%macro isr_no_err_stub 1
isr_stub_%+%1:
    call exception_handler
    iret
%endmacro

extern exception_handler
isr_no_err_stub 0
isr_no_err_stub 1
isr_no_err_stub 2
isr_no_err_stub 3
isr_no_err_stub 4
isr_no_err_stub 5
isr_no_err_stub 6
isr_no_err_stub 7
isr_err_stub    8
isr_no_err_stub 9
isr_err_stub    10
isr_err_stub    11
isr_err_stub    12
isr_err_stub    13
isr_err_stub    14
isr_no_err_stub 15
isr_no_err_stub 16
isr_err_stub    17
isr_no_err_stub 18
isr_no_err_stub 19
isr_no_err_stub 20
isr_no_err_stub 21
isr_no_err_stub 22
isr_no_err_stub 23
isr_no_err_stub 24
isr_no_err_stub 25
isr_no_err_stub 26
isr_no_err_stub 27
isr_no_err_stub 28
isr_no_err_stub 29
isr_err_stub    30
isr_no_err_stub 31
isr_no_err_stub 128
isr_no_err_stub 177

global isr_stub_table
isr_stub_table:
%assign i 0 
%rep    32
    dd isr_stub_%+i ; use DQ instead if targeting 64-bit
%assign i i+1 
%endrep
dd isr_stub_128
dd isr_stub_177

; extern isr_handler
; isr_common_stub:
;     pusha
;     mov eax, ds
;     PUSH eax,
;     PUSH eax, cr2
;     PUSH eax

;     MOV ax, 0x10
;     MOV ds, ax
;     MOV es, ax
;     MOV fs, ax
;     MOV gs, ax

;     PUSH esp
;     CALL isr_handler

;     ADD esp, 8
;     POP ebx
;     MOV ds, bx
;     MOV es, bx
;     MOV fs, bx
;     MOV gs, bx

;     POPA
;     ADD esp, 8
;     STI
;     IRET

