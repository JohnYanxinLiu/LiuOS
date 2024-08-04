
#include "../libc/include/stdint.h"


//Access Byte Masks
#define PRESENT_MASK                1 << 7 // Is the memory segment valid? (always set to 1)
#define PRIVILEDGE_LEVEL_MASK       3 << 6 // CPU Priviledge level, 0 (kernel) is highest, 3 (user application) is lowest
#define TYPE_MASK                   1 << 4 // If 0, it is a system segment. If 1, it defines a code or data segment (beginning will always be 1)
#define EXECUTABLE_MASK             1 << 3 // If 0, it cannot be executed (defines a data segment), If 1, it defines a code segment which can be executed (cannot be written to)
#define DIRECTION_CONFORMING_MASK   1 << 2 // If 0, grows up, if 1, grows down. (we will always be going up, so clear to 0)
#define RW_MASK                     1 << 1 // For code segment, Readable bit, if 1, read is allowed, write is snever allowed | For data segments, writeable bit, if 0, write access is not allowed, if 1, write access is allowed, read access is always allowed.
#define ACCESSED_MASK               1      // Checks if the segment has been accessed.


//Flag Masks
#define GRANULARITY_MASK    1 << 3 // if 0, limit is in 1 byte blocks, if 1, limit is in 4KiB blocks
#define SIZE_MASK           1 << 2 // if 0, 16-bit protected mode, if 1, 32-bit protected mode.(always 1 since we're in 32-bit)
#define LONG_MODE_MASK      1 << 1 // If 1, it defines a 64-bit code segment. For any other type of segment, it should be 0.


typedef struct gdt_entry{
    uint16_t limit_lo;
    uint16_t base_lo;
    uint8_t base_mid;
    uint8_t access_byte;
    uint8_t flags_limit_hi;
    uint8_t base_hi;
}__attribute__((packed)) gdt_entry;


typedef struct gdt_ptr{
    uint16_t limit;
    unsigned int base;
}__attribute__((packed)) gdt_ptr;


typedef struct tss_entry{
    uint32_t LINK;
    uint32_t esp0;
    uint32_t ss0;
    uint32_t esp1;
    uint32_t ss1;
    uint32_t esp2;
    uint32_t ss2;
    uint32_t cr3;
    uint32_t eip;
    uint32_t eflags;
    uint32_t eax;
    uint32_t ecx;
    uint32_t edx;
    uint32_t ebx;
    uint32_t esp;
    uint32_t ebp;
    uint32_t esi;
    uint32_t edi;
    uint16_t es;
    uint16_t reserved_0;
    uint16_t cs;
    uint16_t reserved_1;
    uint16_t ss;
    uint16_t reserved_2;
    uint16_t ds;
    uint16_t reserved_3;
    uint32_t fs;
    uint16_t reserved_4;
    uint32_t gs;
    uint16_t reserved_5;
    uint32_t ldtr;
    uint16_t reserved_6;
    uint16_t reserved_7;
    uint16_t iopb;
    uint32_t ssp;
}__attribute__((packed)) tss_entry;

void init_gdt();

void set_gdt_gate(uint32_t num, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran);

void write_tss(uint32_t num, uint16_t ss0, uint32_t esp0);

