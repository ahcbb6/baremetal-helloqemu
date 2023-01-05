# Borrowed from https://github.com/Codetector1374/GuideOS (no license specified)

# set intel syntax with no prefix on register nor immediate
.intel_syntax noprefix

# Set to 16-bit code mode. We will prepare for protected mode here

.extern stage2_cmain

.code16
.globl stage2_enter_protected

stage2_enter_protected:
    lgdt    gdtdesc
    mov     eax, cr0
    or      eax, 0x1 # PE bit
    mov     cr0, eax

    jmp     (1<<3):start32  # (1 << 3): code segment index * 8 bytes per segment descriptor

.code32
start32:

    mov     ax, (2 << 3)
    mov     ds, ax
    mov     es, ax
    mov     ss, ax

    xor     ax, ax
    mov     fs, ax
    mov     gs, ax

    call    stage2_cmain

halt:
    hlt
    jmp halt

.align 4
gdt:
    # Null Entry
    .short   0, 0
    .byte    0,0,0,0

    # Code Segment
    .short 0xFFFF, 0
    .byte 0
    .byte 0b10011010
    .byte 0b11001111
    .byte 0

    # Data Segment
    .short 0xFFFF, 0
    .byte 0
    .byte 0b10010010
    .byte 0b11001111
    .byte 0

gdtdesc:
    .short   (gdtdesc - gdt - 1)
    .long   gdt

