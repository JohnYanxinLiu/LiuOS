/* Link.ld -- Linker script for the kernel - ensure everything goes in the */
/*            Correct place.  */
/*            Original file taken from Bran's Kernel Development */
/*            tutorials: http://www.osdever.net/bkerndev/index.php. */

ENTRY(start)
SECTIONS
{

    . = 1M;

    ImageBase = .;

    .text ALIGN(4k) :
    {
        KEEP(*(.multiboot_header))   /* first the multiboot header */
        code = .; _code = .; __code = .;
        *(.text)
    }

    .data ALIGN(4k) : 
    {
        data = .; _data = .; __data = .;
        *(.data)
        *(.rodata)
    }

    .bss ALIGN(4k) :
    {
        bss = .; _bss = .; __bss = .;
        *(.bss)
    }

    end = .; _end = .; __end = .;
}

