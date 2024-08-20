#include "include/keyboard.h"
#include "libc/include/stdint.h"
#include "libc/include/stdio.h"
#include "include/drivers.h"
#include "include/vga.h"


void keyboard_handler(interrupt_registers *regs)
{
    char data = inb(0x60);

    char scan_code = data & 0x7F; // What key was pressed

    char press = data & 0x80; // Pressed or released

    print("Keyboard\r\n");

    // printf("Scan Code: %d, Press: %d\r\n", scan_code, press);

}


void init_keyboard()
{
    irq_install_handler(1, &keyboard_handler);
}
