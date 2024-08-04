#include "libc/include/stdint.h"
#include "include/vga.h"
#include "include/gdt.h"
#include "include/idt.h"


void kmain(void);

void kmain()
{
    init_gdt();
    init_idt();
    print("init_gdt and idt finished!\r\n");
}