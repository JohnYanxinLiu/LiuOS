
#ifndef IDT_H
#define IDT_H

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

typedef struct interrupt_registers{
   uint32_t cr2;
   uint32_t ds;
   uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
   uint32_t int_no, err_code;
   uint32_t eip, csm, eflags, useresp, ss;
} interrupt_registers;

void isr_handler(interrupt_registers* regs);

void irq_install_handler (int irq, void (*handler) (interrupt_registers *r));

void irq_uninstall_handler(int irq);

extern void isr_0  ();
extern void isr_1  ();
extern void isr_2  ();
extern void isr_3  ();
extern void isr_4  ();
extern void isr_5  ();
extern void isr_6  ();
extern void isr_7  ();
extern void isr_8  ();
extern void isr_9  ();
extern void isr_10 ();
extern void isr_11 ();
extern void isr_12 ();
extern void isr_13 ();
extern void isr_14 ();
extern void isr_15 ();
extern void isr_16 ();
extern void isr_17 ();
extern void isr_18 ();
extern void isr_19 ();
extern void isr_20 ();
extern void isr_21 ();
extern void isr_22 ();
extern void isr_23 ();
extern void isr_24 ();
extern void isr_25 ();
extern void isr_26 ();
extern void isr_27 ();
extern void isr_28 ();
extern void isr_29 ();
extern void isr_30 ();
extern void isr_31 ();

extern void irq_0  ();
extern void irq_1  ();
extern void irq_2  ();
extern void irq_3  ();
extern void irq_4  ();
extern void irq_5  ();
extern void irq_6  ();
extern void irq_7  ();
extern void irq_8  ();
extern void irq_9  ();
extern void irq_10 ();
extern void irq_11 ();
extern void irq_12 ();
extern void irq_13 ();
extern void irq_14 ();
extern void irq_15 ();

extern void isr_128();
extern void isr_177();

#endif //IDT_H