
#ifndef TIMER_H
#define TIMER_H

#include "idt.h"

void init_timer();

void onIRQ0 (interrupt_registers *regs);



#endif // TIMER_H