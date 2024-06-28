#include "include/stdint.h"
#include "include/vga.h"

void kmain(void);

void kmain()
{
    Reset();
    print("hello world!\r\n\n");
    print("hello world!\r\n\n");
    print("hello world!\r\n");
    for (uint16_t i = 0; i < 19; i++)
    {
        print("\n");
    }
    print("end");
    // Reset();
}