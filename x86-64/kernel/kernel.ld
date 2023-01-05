/* Borrowed from https://github.com/Codetector1374/GuideOS (no license specified) */

/* Kernel Linker Script */
ENTRY(_start)
SECTIONS {
    . = 1M;
    raw_init : {
        KEEP(*(.raw_init))
    }
    multiboot BLOCK(8) : {
        KEEP(*(.multiboot))
    }
    bootstrap : {
        *(.bootstrap)
    }
    bootstrap.data BLOCK(4k) : {
        *(.bootstrap.data)
    }
    kernel_start_pa = .;

    kernel.text (0xFFFF800000000000 + kernel_start_pa) : AT (kernel_start_pa) {
        *(.text .text.*)
    }
    . = ALIGN(4k);
    kernel.bss : {
        *(.bss .bss.*)
    } =0
    kernel.data : {
        *(.data .data.*)
    }
    . = ALIGN(4k);
    kernel.rodata : {
        *(.rodata .rodata.*)
    }
    . = ALIGN(4k);
    kern_end = .;
    /DISCARD/ : {
        *(.eh_frame)
    }
}
