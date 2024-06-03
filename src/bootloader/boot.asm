org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ;NASM Macro for newline char
%define DIR_ENTRY_SIZE 32 ; size of a directory entry
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
    ; set up data segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; set up stack
    mov ss, ax      ; Sets stack segment to 0
    mov sp, 0x7C00  ; Sets stack pointer to beginning of this file.

    push es
    push word .after
    retf

.after:

    mov [ebr_drive_number], dl

    ; show booting msg
    mov si, msg_booting
    call puts

    ; Read FAT root directory
    ; Calculate lba of root dir = reserved + fats * sectors per fat and read into memory
    mov ax, [bpb_sectors_per_fat]
    mov bl, [bpb_fats]
    xor bx, bx                          ; clear bx
    mul bx                              ; ax = fats * sectors per fat
    add ax, [bpb_reserved_clusters]                  ; ax = lba of root dir
    push ax

    ; calculate size of root directories = (32 * num dirs) / bytes per sector
    mov ax, [bpb_sectors_per_fat]       ; ax = number of dir entries in a fat
    shl ax, 5                           ; ax *= 5
    div word [bpb_bytes_per_sector]     ; ax = number of sectors to read

    test dx, dx     
    jz .root_dir_after                   
    inc ax                              ; ax += 1

.root_dir_after:
    
    ; read root dir
    mov cl, al                          ; cl = num sectors to read
    pop ax                              ; ax = lba of root dir
    mov dl, [ebr_drive_number]          ; dl = drive number
    mov bx, buffer                      ; es:bs = buffer
    call disk_read

    ;search for kernel.bin
    xor bx, bx
    mov di, buffer

.search_kernel:
    mov si, file_kernel_bin
    mov cx, 11                          ; compares up to 11 chars
    push di
    repe cmpsb                               ; hint: cmsb compares bytes at memory addr in ds:si and es:di, si and di are incremented when direction flag = 0. decremented when dir flag = 1
                                            ;     : repe repeats while operands are equal (zero flag = 1) or until cx = 0
    pop di
    je .found_kernel

    add di, 32
    inc bx
    cmp bx, [bpb_root_dirs]
    jl .search_kernel

    jmp kernel_not_found_error

.found_kernel:
    ; di should have the address to the entry
    mov ax, [di + 26]                   ; first logical cluster
    mov [kernel_cluster], ax

    ;load FAT from disk to memory
    mov ax, [bpb_reserved_clusters]
    mov ax, buffer
    mov cl, [bpb_sectors_per_fat]
    mov dl, [ebr_drive_number]
    call disk_read

    ; read kernel and process FAT chain
    mov bx, KERNEL_LOAD_SEGMENT
    mov es, bx 
    mov bx, KERNEL_LOAD_OFFSET

.load_kernel_loop:
    ; read next cluster
    mov ax, [kernel_cluster]
    add ax, 31                          ; first cluster = (kernel_cluster - 2) * sectors_per_cluster + Start_sector
                                        ; start sector = reserved + fats * root dir size = 1 + 18 +134 = 33

    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    add bx, [bpb_bytes_per_sector]

    ; compute location of next cluster
    mov ax, [kernel_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx                              ; ax = index of entry in FAT, dx = cluster mod 2

    mov si, buffer
    add si, ax
    mov ax, [ds:si]

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_clusters_after

.even:
    and ax, 0x0FFF

.next_clusters_after:
    cmp ax, 0x0FF8                      ; end of chain
    jne .read_finish

    mov [kernel_cluster], ax
    jmp .load_kernel_loop

.read_finish:

    ; boot device in dl
    mov dl, [ebr_drive_number]

    ; set segment registers
    mov ax, KERNEL_LOAD_SEGMENT
    mov ds, ax
    mov es, ax

    jmp KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET

    jmp wait_key_and_reboot

    cli
    hlt


;
; Error Handlers
;
floppy_error:
    mov si, msg_read_failed
    call puts               ; prints disk read fail message
    jmp wait_key_and_reboot

kernel_not_found_error:
    mov si, msg_kernel_not_found
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


msg_booting:            db 'booting...', ENDL, 0
msg_read_failed:        db 'Disk read failed. Press any key to retry', ENDL, 0
msg_kernel_not_found:   db 'Kernel.bin not found!!!', ENDL, 0
file_kernel_bin:        db 'KERNEL  BIN'
kernel_cluster:         dw 0

KERNEL_LOAD_SEGMENT equ 0x2000
KERNEL_LOAD_OFFSET  equ 0

;
; Partition Signature
;

times 510-($-$$) db 0
dw 0xAA55

buffer: