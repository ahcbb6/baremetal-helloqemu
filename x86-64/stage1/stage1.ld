/* Borrowed from https://github.com/Codetector1374/GuideOS (no license specified) */

/* Linker Script for the Stage 1 Bootloader */

/*
 * we use this "boot" memory region to make sure we throw an
 * error if we ever go over 512 bytes in the 1 stage binary
 */
MEMORY {
    boot : ORIGIN = 0x7C00, LENGTH = 512
}

ENTRY(start)
SECTIONS {
    text 0x7C00 : {
        *(.text.init)
        *(.text .text*)
    } >boot
    .rodata : {
        *(.rodata)
    } >boot

    .bss : {
        *(.bss)
    } >boot
    .data : {
        *(.data)
    } >boot
    .bootsign (0x7C00 + 510) : {
        BYTE(0x55)
        BYTE(0xAA)
    } >boot
    /DISCARD/ : {
        *(.debug*)
    }
}
