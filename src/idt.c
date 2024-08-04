#include "include/idt.h"
#include "include/drivers.h"
#include "libc/include/string.h"
#include "include/drivers.h"

extern void idt_flush(uint32_t);


static bool idt_gate_entries[IDT_MAX_DESCRIPTORS];
extern uint32_t isr_stub_table[];


void init_idt(){
    idtr.limit = sizeof(idt_gate_t) * 256 - 1;
    idtr.base = (uint32_t) &idt_entries;
    
    memset(&idt_entries, 0, sizeof(idt_gate_t) * 256);

    PIC_init(0x20, 0x28);

    for (uint8_t entry_num = 0; entry_num < 34; entry_num++) {
        set_idt_gate(entry_num, isr_stub_table[entry_num], 0x08, 0x8E);
        idt_gate_entries[entry_num] = true;
    }

    __asm__ volatile ("lidt %0" : : "m"(idtr)); //load the IDT
    __asm__ volatile ("sti"); // set interrupt flag.
    // idt_flush((uint32_t)&idtr);
}


void exception_handler() {
    __asm__ volatile ("cli; hlt"); // Completely hangs the computer
}

void set_idt_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags)
{
    idt_gate_t* gate = &idt_entries[num];

    gate->offset_lo         = (uint32_t)base & 0xFFFF;
    gate->ss                = sel; // this value can be whatever offset your kernel code selector is in your GDT
    gate->type_attributes   = flags;
    gate->offset_hi         = (uint32_t)base >> 16;
    gate->reserved          = 0;
}
