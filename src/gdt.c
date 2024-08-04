#include "include/gdt.h"
#include "libc/include/string.h"


extern void gdt_flush(uint32_t);

extern void tss_flush();

#define NUM_ENTRIES 6

gdt_entry gdt_entries[NUM_ENTRIES];
gdt_ptr gdt;
tss_entry tss;

void init_gdt()
{
    gdt.limit = (sizeof(gdt_entry) * NUM_ENTRIES) - 1;
    gdt.base = (uint32_t)&gdt_entries;

    set_gdt_gate(0, 0, 0, 0, 0); // NULL Segment
    set_gdt_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xC); // Kernel Code Segment
    set_gdt_gate(2, 0, 0xFFFFFFFF, 0x92, 0xC); // Kernel Data Segment
    set_gdt_gate(3, 0, 0xFFFFFFFF, 0xFA, 0xC); // User Code Segment
    set_gdt_gate(4, 0, 0xFFFFFFFF, 0xF2, 0xC); // User Data Segment
    write_tss(5, 0x10, 0x0);
    
    gdt_flush((uint32_t)&gdt);
    tss_flush();
}

void write_tss(uint32_t num, uint16_t ss0, uint32_t esp0)
{
    uint32_t base = (uint32_t) &tss;
    uint32_t limit = base + sizeof(tss);

    set_gdt_gate(num, base, limit, 0xE9, 0x00);

    memset(&tss, 0, sizeof(tss));

    tss.ss0 = ss0;
    tss.esp0 = esp0;

    tss.cs = 0x08 | 0x3;
    
    tss.ss = tss.ds = tss.es = tss.fs = 
    tss.gs = 0x10 | 0x3;



}

//upper 4 bits of flags and upper 12 bits of limit will be ignored
void set_gdt_gate(uint32_t num, uint32_t base, uint32_t limit, uint8_t access, uint8_t flags)
{
    gdt_entries[num].access_byte = access;
    
    gdt_entries[num].base_lo  = base & 0xFFFF;
    gdt_entries[num].base_mid = (base >> 16) & 0xFF;
    gdt_entries[num].base_hi  = (base >> 24) & 0xFF;
    
    gdt_entries[num].limit_lo = limit & 0xFFFF;
    gdt_entries[num].flags_limit_hi = (flags << 4 ) | ((limit >> 16) & 0xF);
}





