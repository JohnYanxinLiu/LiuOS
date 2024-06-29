#include "include/gdt.h"



extern void gdt_flush(uint32_t);

#define NUM_ENTRIES 5

gdt_entry gdt_entries[NUM_ENTRIES];
struct gdt_ptr gdt;


void init_gdt()
{
    gdt.limit = (sizeof(gdt_entry) * NUM_ENTRIES) - 1;
    gdt.base = (uint32_t)&gdt_entries;

    set_gdt_gate(0, 0, 0, 0, 0); // NULL Segment
    set_gdt_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xC); // Kernel Code Segment
    set_gdt_gate(2, 0, 0xFFFFFFFF, 0x92, 0xC); // Kernel Data Segment
    set_gdt_gate(3, 0, 0xFFFFFFFF, 0xFA, 0xC); // User Code Segment
    set_gdt_gate(4, 0, 0xFFFFFFFF, 0xF2, 0xC); // User Data Segment

    gdt_flush((uint32_t)&gdt);
}


//upper 4 bits of flags and upper 12 bits of limit will be ignored
void set_gdt_gate(uint32_t num, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran)
{
    gdt_entries[num] |= (((uint64_t)limit >> LOW_LIMIT_BIT_POS) & LOW_LIMIT_MASK) << SEGMENT_LOW_LIMIT_OFFSET;
    gdt_entries[num] |= (((uint64_t)limit >> UPPER_LIMIT_BIT_POS) & UPPER_LIMIT_MASK) << SEGMENT_UPPER_LIMIT_OFFSET;
    
    gdt_entries[num] |= (((uint64_t)base >> LOW_BASE_BIT_POS) & LOW_BASE_MASK) << SEGMENT_LOW_BASE_OFFSET;
    gdt_entries[num] |= (((uint64_t)base >> MID_BASE_BIT_POS) & MID_BASE_MASK) << SEGMENT_MID_BASE_OFFSET;
    gdt_entries[num] |= (((uint64_t)base >> UPPER_BASE_BIT_POS) & UPPER_BASE_MASK) << SEGMENT_UPPER_BASE_OFFSET;
    
    gdt_entries[num] |= ((uint64_t)access & ACCESS_BYTE_MASK) << SEGMENT_ACCESS_BYTE_OFFSET;
    gdt_entries[num] |= ((uint64_t)gran & FLAGS_MASK) << SEGMENT_FLAGS_OFFSET;
}





