
#include "include/drivers.h"

void outb(uint16_t port, uint8_t value)
{
    asm volatile ("outb %b0, %w1" : : "a"(value), "Nd"(port) : "memory");
}	


uint8_t inb(uint16_t port)
{
    uint8_t ret;
    __asm__ volatile ( "inb %w1, %b0"
                   : "=a"(ret)
                   : "Nd"(port)
                   : "memory");
    return ret;
}

void io_wait(void)
{
    outb(0x80, 0);
}

/*
 *  PARAMS:
 *	- offset1 - vector offset for master PIC vectors on the master become offset1..offset1+7
 *	- offset2 - same for slave PIC: offset2..offset2+7
*/
void PIC_init(int offset1, int offset2)
{
    uint8_t a1, a2;
	
	a1 = inb(PIC1_DATA);                        // save masks
	a2 = inb(PIC2_DATA);
	
	outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);  // starts the initialization sequence (in cascade mode)
	io_wait();
	outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
	io_wait();
	outb(PIC1_DATA, offset1);                 // ICW2: Master PIC vector offset
	io_wait();
	outb(PIC2_DATA, offset2);                 // ICW2: Slave PIC vector offset
	io_wait();
	outb(PIC1_DATA, 4);                       // ICW3: tell Master PIC that there is a slave PIC at IRQ2 (0000 0100)
	io_wait();
	outb(PIC2_DATA, 2);                       // ICW3: tell Slave PIC its cascade identity (0000 0010)
	io_wait();
	
	outb(PIC1_DATA, ICW4_8086);               // ICW4: have the PICs use 8086 mode (and not 8080 mode)
	io_wait();
	outb(PIC2_DATA, ICW4_8086);
	io_wait();
	
	outb(PIC1_DATA, a1);   // restore saved masks.
	outb(PIC2_DATA, a2);
}

void pic_disable(void) 
{
    outb(PIC1_DATA, 0xff);
    outb(PIC2_DATA, 0xff);
}