#include "include/idt.h"
#include "libc/include/string.h"
#include "include/vga.h"
#include "include/drivers.h"


extern void idt_flush(uint32_t);


// static bool idt_gate_entries[IDT_MAX_DESCRIPTORS];

void init_idt(){
    idtr.limit = sizeof(idt_gate_t) * 256 - 1;
    idtr.base = (uint32_t) &idt_entries;
    
    memset(&idt_entries, 0, sizeof(idt_gate_t) * 256);

    PIC_init(0x20, 0x28);

    
    set_idt_gate(0,   (uint32_t)isr_0,   0x08, 0x8E);
    set_idt_gate(1,   (uint32_t)isr_1,   0x08, 0x8E);
    set_idt_gate(2,   (uint32_t)isr_2,   0x08, 0x8E);
    set_idt_gate(3,   (uint32_t)isr_3,   0x08, 0x8E);
    set_idt_gate(4,   (uint32_t)isr_4,   0x08, 0x8E);
    set_idt_gate(5,   (uint32_t)isr_5,   0x08, 0x8E);
    set_idt_gate(6,   (uint32_t)isr_6,   0x08, 0x8E);
    set_idt_gate(7,   (uint32_t)isr_7,   0x08, 0x8E);
    set_idt_gate(8,   (uint32_t)isr_8,   0x08, 0x8E);
    set_idt_gate(9,   (uint32_t)isr_9,   0x08, 0x8E);
    set_idt_gate(10,  (uint32_t)isr_10,  0x08, 0x8E);
    set_idt_gate(11,  (uint32_t)isr_11,  0x08, 0x8E);
    set_idt_gate(12,  (uint32_t)isr_12,  0x08, 0x8E);
    set_idt_gate(13,  (uint32_t)isr_13,  0x08, 0x8E);
    set_idt_gate(14,  (uint32_t)isr_14,  0x08, 0x8E);
    set_idt_gate(15,  (uint32_t)isr_15,  0x08, 0x8E);
    set_idt_gate(16,  (uint32_t)isr_16,  0x08, 0x8E);
    set_idt_gate(17,  (uint32_t)isr_17,  0x08, 0x8E);
    set_idt_gate(18,  (uint32_t)isr_18,  0x08, 0x8E);
    set_idt_gate(19,  (uint32_t)isr_19,  0x08, 0x8E);
    set_idt_gate(20,  (uint32_t)isr_20,  0x08, 0x8E);
    set_idt_gate(21,  (uint32_t)isr_21,  0x08, 0x8E);
    set_idt_gate(22,  (uint32_t)isr_22,  0x08, 0x8E);
    set_idt_gate(23,  (uint32_t)isr_23,  0x08, 0x8E);
    set_idt_gate(24,  (uint32_t)isr_24,  0x08, 0x8E);
    set_idt_gate(25,  (uint32_t)isr_25,  0x08, 0x8E);
    set_idt_gate(26,  (uint32_t)isr_26,  0x08, 0x8E);
    set_idt_gate(27,  (uint32_t)isr_27,  0x08, 0x8E);
    set_idt_gate(28,  (uint32_t)isr_28,  0x08, 0x8E);
    set_idt_gate(29,  (uint32_t)isr_29,  0x08, 0x8E);
    set_idt_gate(30,  (uint32_t)isr_30,  0x08, 0x8E);
    set_idt_gate(31,  (uint32_t)isr_31,  0x08, 0x8E);


    set_idt_gate(32,  (uint32_t)irq_0,   0x08, 0x8E);
    set_idt_gate(33,  (uint32_t)irq_1,   0x08, 0x8E);
    set_idt_gate(34,  (uint32_t)irq_2,   0x08, 0x8E);
    set_idt_gate(35,  (uint32_t)irq_3,   0x08, 0x8E);
    set_idt_gate(36,  (uint32_t)irq_4,   0x08, 0x8E);
    set_idt_gate(37,  (uint32_t)irq_5,   0x08, 0x8E);
    set_idt_gate(38,  (uint32_t)irq_6,   0x08, 0x8E);
    set_idt_gate(39,  (uint32_t)irq_7,   0x08, 0x8E);
    set_idt_gate(40,  (uint32_t)irq_8,   0x08, 0x8E);
    set_idt_gate(41,  (uint32_t)irq_9,   0x08, 0x8E);
    set_idt_gate(42,  (uint32_t)irq_10,  0x08, 0x8E);
    set_idt_gate(43,  (uint32_t)irq_11,  0x08, 0x8E);
    set_idt_gate(44,  (uint32_t)irq_12,  0x08, 0x8E);
    set_idt_gate(45,  (uint32_t)irq_13,  0x08, 0x8E);
    set_idt_gate(46,  (uint32_t)irq_14,  0x08, 0x8E);
    set_idt_gate(47,  (uint32_t)irq_15,  0x08, 0x8E);
    
    set_idt_gate(128, (uint32_t)isr_128, 0x08, 0x8E);
    set_idt_gate(177, (uint32_t)isr_177, 0x08, 0x8E);



    __asm__ volatile ("lidt %0" : : "m"(idtr)); //load the IDT
    __asm__ volatile ("sti"); // set interrupt flag.
    // idt_flush((uint32_t)&idtr);
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

unsigned char *exception_messages[] = {
    "Division By Zero",
    "Debug",
    "Non maskable Interrupt",
    "Breakpoint",
    "Into Detected Overflow",
    "Out of Bounds",
    "Invalid Opcode",
    "No Coprocessor",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Bad TSS",
    "Segment Not Present",
    "Stack Fault",
    "General Protection Fault",
    "Page Fault",
    "Unknown Interrupt",
    "Coprocessor Fault",
    "Alignment Fault",
    "Machine Check",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
};

void isr_handler(interrupt_registers *regs){
    if (regs->int_no < 32){
        print(exception_messages[regs->int_no]);
        print("\n");
        print("Exception! System Halted!\n");
        __asm__ volatile ("cli; hlt"); // Completely hangs the computer
    }
}

void *irq_routines[16] = {
    0, 0, 0, 0, 
    0, 0, 0, 0,
    0, 0, 0, 0, 
    0, 0, 0, 0
};

void irq_install_handler (int irq, void (*handler) (interrupt_registers *r)){
    irq_routines[irq] = handler;
}



void irq_uninstall_handler(int irq){
    irq_routines[irq] = 0;
}


void irq_handler(interrupt_registers* regs){
    void (*handler)(interrupt_registers * regs);

    handler = irq_routines[regs->int_no - 32];

    if(handler){
        handler(regs);
    }

    if(regs->int_no >= 40){
        outb(0xA0, 0x20);
    }

    outb(0x20, 0x20);
}