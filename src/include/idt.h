

#include "../libc/include/stdint.h"

#define TASK_GATE 0x5;

#define INTERRUPT_GATE_16 0x6
#define TRAP_GATE_16 0x7

#define INTERRUPT_GATE_32 0xE
#define TRAP_GATE_32 0xF

#define IDT_MAX_DESCRIPTORS 256


typedef struct {
    uint16_t offset_lo;         // offset bits 0:15
    uint16_t ss;                // segement selector pointing to segment in gdt or idt
    uint8_t reserved;           // reserved, set to 0
    uint8_t type_attributes;    // [0:3] : gate type, [5:6] : dpl, and [7] : p fields
    uint16_t offset_hi;         // offset bits 16:31
}__attribute__((packed)) idt_gate_t;


typedef struct{
    uint16_t limit;
    uint32_t base;
}__attribute__((packed)) idtr_ptr;


__attribute__((aligned(0x10))) 
static idt_gate_t idt_entries[256]; // Create an array of IDT entries; aligned for performance

static idtr_ptr idtr;

void init_idt();
void set_idt_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags);

// __attribute__((noreturn))
void exception_handler(void);


void set_idt_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags);