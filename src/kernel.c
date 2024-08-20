#include "libc/include/stdint.h"
#include "include/vga.h"
#include "include/gdt.h"
#include "include/idt.h"
#include "include/timer.h"
#include "include/keyboard.h"



void kmain(void);

void kmain()
{
    init_gdt();
    init_idt();
    print("init_gdt and idt finished!\r\n");
    init_timer();
    init_keyboard();
    for(;;);
}