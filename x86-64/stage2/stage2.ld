/* Borrowed from https://github.com/Codetector1374/GuideOS (no license specified) */

/* Linker Script for the Stage 2 Bootloader */

MEMORY {
    stage2 : ORIGIN = 0x7E00, LENGTH = 32k
}

ENTRY(stage2)
SECTIONS {
    text : {
        *(.text.start)
        *(.text .text*)
    } >stage2
    .rodata : {
        *(.rodata .rodata.*)
    } >stage2

    .bss : {
        *(.bss .bss.*)
    } >stage2
    .data : {
        *(.data .data.*)
    } >stage2
    /DISCARD/ : {
        *(.debug*)
    }
}
