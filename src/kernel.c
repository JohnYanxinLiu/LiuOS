#include "include/stdint.h"
#include "include/vga.h"
#include "include/gdt.h"


void kmain(void);

void kmain()
{
    init_gdt();
    print("init_gdt finished!\r\n");
}