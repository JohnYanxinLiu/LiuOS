org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ;NASM Macro for newline char

;
; FAT12 Header
;
db 0xEB, 0x3C, 0x90

;
; OEM
;

bpb_oem:                    db 'MSWIN4.1'       ; 8 bytes
bpb_bytes_per_sector:       dw 512
bpb_sectors_per_cluster:    db 1
bpb_reserved_clusters:      dw 1
bpb_fats:                   db 2
bpb_root_dirs:              dw 0xE0
bpb_sectors:                dw 2880             ;2880 * 512 kB = 1440kB
bpb_media_descriptor:       db 0xF0
bpb_sectors_per_fat:        dw 9
bpb_sectors_per_track:      dw 0x12
bpb_sides:                  dw 0x02
bpb_hidden_sectors:         dd 0
bpb_large_sector_count:     dd 0


;
; Extended boot records
;

ebr_drive_number:           db 0
ebr_windows_nt_flags:       db 0
ebr_signature:              db 0x29
ebr_volume_id:              dd 0xFBF70E5E
ebr_volume_label:           db 'hummus     '    ; 11 Bytes
ebr_sys_id_str:             db 'FAT12  '        ; 8 Bytes

;
; Boot code
;

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

    ; calls hello_world
    mov si, str_hello
    call puts

    hlt

.halt:
    jmp .halt


str_hello: db 'Hello World!', ENDL, 0



;
; Partition Signature
;

times 510-($-$$) db 0
dw 0xAA55