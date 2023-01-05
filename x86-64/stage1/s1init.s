# Borrowed from https://github.com/Codetector1374/GuideOS (no license specified)

# set intel syntax with no prefix on register nor immediate
.intel_syntax noprefix

#
# We place the following code in the .text.init section so we can place
# it at a location we want using the linker script (0x7c00)
#
.section .text.init

# Set to 16-bit code mode. Since we are going to start in 16-bit real mode.
.code16
.globl start

start:
    #
    # This jump is not strictly necessary, but some BIOS will start you at 0x07C0:0000
    # which is in fact the linear address as 0x0:7C00, but the range of jump will be
    # different. We will unify that with this long jump.
    #
    jmp 0:true_start

.section .text

true_start:
    cli     # disable interrupts

    # We zero the segment registers
    xor     ax, ax
    mov     ds, ax
    mov     es, ax
    mov     ss, ax

    mov     sp, 0x7C00   # SP is loaded with 0x7C00, we can use all that memory below code as stack.

# Clear Screen and set video mode to 2
    mov     ah, 0
    mov     al, 2
    int     0x10

    mov     si, OFFSET starting_string
    call    print_string

# We need to store our drive number onto the stack (DL)
    push   dx   # Let's just push the entire DX register

    mov     si, OFFSET loading_string
    call    print_string

#
# Now that we are done printing, we can restore our DX register
# and prepare for the BIOS call to load the next few sectors to
# memory.
#
# First test to make sure LBA addressing mode is supported. This
# is generally not supported on floppy drives
#
    mov     ah, 0x41
    mov     bx, 0x55aa
    int     0x13
    jc      error_no_ext_load
    cmp     bx, 0xaa55
    jnz     error_no_ext_load

# If all is well, we will load the first 64x(512B) blocks to 0x7E00

    mov     si, offset disk_address_block
    mov     ah, 0x42
    int     0x13
    jc      error_load # Carry is set if there is error while loading
    mov     si, offset success_str
    call    print_string

# goto stage 2
    jmp     0:0x7E00
end:
    hlt
    jmp     end

error_no_ext_load:
    mov     si, offset error_str_no_ext
    call    print_string
    jmp     end

error_load:
    mov     si, offset error_str_load
    call    print_string
    jmp     end

# Print string pointed to by DS:SI using
# BIOS TTY output via int 10h/AH=0eh

print_string:
    push    ax
    push    si
    push    bx
    xor     bx, bx
    mov     ah, 0xe       # int 10h 'print char' function

repeat:
    lods    al, [si]   # Get character from string
    test    al, al
    je      done         # If char is zero, end of string
    int     0x10           # Otherwise, print it
    jmp     repeat
done:
    pop bx
    pop si
    pop ax
    ret

starting_string:
    .ascii "Starting Stage 1 Bootloader\r\n"
    .byte 0
loading_string:
    .ascii "Loading Stage 2 Bootloader\r\n"
    .byte 0
error_str_no_ext:
    .ascii "no EXT load\r\n"
    .byte 0
error_str_load:
    .ascii "Failed to load sectors\r\n"
    .byte 0
success_str:
    .ascii "Stage 2 Loaded.\r\nJumping to Stage2 Bootloader\r\n"
    .byte 0

disk_address_block:
    .byte       0x10    # length of this block
    .byte       0x0     # reserved
    .short      64      # number of blocks = 32k/512b = 64
    .long       0x07E00000  # Target memory address
    .quad       1       # Starting Disk block 1, since we just need to skip the boot sector.

