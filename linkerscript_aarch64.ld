/* Use the _start symbol as entry point */
ENTRY(_start)
SECTIONS{
        /* Ram starts at 0x40000000 */
        /*
        QEMU when given -kernel adds an offset of
        0x00080000 for 64-bit ARM (KERNEL64_LOAD_ADDR)
        */
        . = 0x40080000 ;
        /* Put startup code at the beginning */
        /* Only put the text section of startup.o */
        /* Put all other sections from others */
        .stub : { startup.o(.text) }
        .text : { *(.text) }
        .rodata : { *(.rodata) }
        .data : { *(.data) }
        /* Put common symbols from bss on the bss section */
        .bss : { *(.bss COMMON) }

        /* Use 64KB for stack */
        . = ALIGN(8);
        stack_bottom = .;
        . += 0x10000;
        stack_top = .;
}
