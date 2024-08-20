#ifndef KEYBOARD_H
#define KEYBOARD_H

#include "idt.h"

void init_keyboard();

void keyboard_handler(interrupt_registers *regs);


#endif // KEYBOARD_H