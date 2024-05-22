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
ebr_sys_id_str:             db 'FAT12   '       ; 8 Bytes

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
    
    or al, al       ; checks if al register is null
    jz .done       ; jumps if al is not 0

    ; Takes char from al to write
    mov ah, 0x0e    ; Call bios INT
    mov bh, 0       ; Sets page number to 0
    int 0x10

    jmp .loop
    ; Ignore BL foreground pixel (only for graphics mode)

.done:
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

    mov [ebr_drive_number], dl

    mov ax, 1
    mov cl, 1
    mov bx, 0x7E00
    call disk_read


    ; calls hello_world
    mov si, msg_hello
    call puts
    
    cli
    hlt


;
; Error Handlers
;
floppy_error:
    mov si, msg_read_failed
    call puts               ; prints disk read fail message
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 0x16                ; wait for key press
    jmp 0x0FFFF:0x0         ; jump to beginning of BIOS to reboot

.halt:
    cli                     ; Disables interrupts
    hlt                     ; Stays in halt state


;
; Disk Routines
;

; sector    = (LBA % sectors per track) + 1
; side      = (LBA / sectors per track) % sides
; cylinder  = (LBA / sectors per track) / sides

; Converts LBA to Disk Address

; Requires:
;   - ax = LBA address
; Ensures
;   - cx [0:5]  = sector
;   - cx [6:15] = cylinder
;   - dh        = side


lba_to_chs:

    push ax
    push dx
    
    xor dx, dx                          ; clears dx
    div word [bpb_sectors_per_track]    ; ax = LBA / sectors per track
                                        ; dx = LBA % sectors per track

    mov cx, dx                          ; cx = (LBA % sectors per track)
    inc cx                              ; cx = (LBA % sectors per track) + 1 = sector
    
    div word [bpb_sides]                ; ax = (LBA / sectors per track) / sides = cylinder
                                        ; dx = (LBA / sectors per track) % sides = side


    mov ch, al                          ; cx [8:15] = cylinder [0:7]
    shl ah, 6                           ; ah [7:8] = cylinder[14:15]

    or cl, ah                           ; cx [0:5]  = sector
                                        ; cx [6:15] = cylinder

    mov dh, dl                          ; dh = side


    ; pop dx
    ; pop ax

    ; Does this actually matter? I don't really see the issue in just restoring all of dx
    pop ax
    mov dl, al
    pop ax
    ret

;
; Reads sectors from disk
; Requires:
;   - ax = LBA address
;   - cl = number of sectors to read (up to 128)
;   - dl = drive number
;   - es:bx = memory address to store read data
;

disk_read:

    push ax                 ; save modified registers
    push bx
    push cx
    push dx
    push di

    push cx                 ; saves cl (number of sectors to read)
    call lba_to_chs         ;   
    pop ax                  ; ax = number of sectors to read
    
    mov ah, 0x02

    mov di, 3               ; i = 3

.retry:
    pusha                   ; saves all registers
    stc                     ; sets carry flags
    int 0x13
    jnc .done               ; if carry flag is cleared, then successful

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry              ; disk read failed loop with i--

    ; tried 3 times and failed
.fail
    jmp floppy_error

.done:
    popa

    pop di                  ; restore modified registers
    pop dx
    pop cx
    pop bx
    pop ax
    

;
; Resets disk controller
; Requires:
;   - dl = drive number

disk_reset:
    pusha
    mov ah, 0
    stc
    int 0x13
    jc floppy_error         ; if read fails, then jump to floppy error
    popa
    ret



msg_hello:          db 'Hello World!', ENDL, 0
msg_read_failed:    db 'Disk read failed. Press any key to retry', ENDL, 0


;
; Partition Signature
;

times 510-($-$$) db 0
dw 0xAA55