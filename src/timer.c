#include "include/timer.h"
#include "libc/include/stdint.h"
#include "include/idt.h"
#include "include/vga.h"
#include "include/drivers.h"

uint64_t ticks;
const uint32_t freq = 100;


void onIRQ0(interrupt_registers *regs)
{
    ticks++;
    // print("Timer Ticked\n");
}

void init_timer()
{
    ticks = 0;
    irq_install_handler(0, &onIRQ0);

    // Oscillator runs at 119318 Hz
    uint32_t divisor = 1193180/freq;


    //0x43 is the mode/command register | 0011 (lobyte/hibyte) 0110 (squarewave generator)
    outb(0x43, 0x36);
    outb(0x40, (uint8_t)(divisor & 0xFF));
    outb(0x40, (uint8_t)(divisor >> 8) * 0xFF);
}


