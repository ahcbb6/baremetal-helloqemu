# Borrowed from https://github.com/Codetector1374/GuideOS (no license specified)

# set intel syntax with no prefix on register nor immediate
.intel_syntax noprefix

# Set to 16-bit code mode. Since we are going to start in 16-bit real mode.
.code16
.globl stage2

.extern stage2_enter_protected

.section .text.start

stage2:
    cli     # disable interrupts

    # We zero the segment registers
    xor     ax, ax
    mov     ds, ax
    mov     es, ax
    mov     ss, ax

    mov     sp, OFFSET stage2   # SP is loaded with 0x7E00, we can use all that memory below code as stack.

# We need to store our drive number
    mov     [drive_number], edx

    lea     si, loading_string
    call    print_string

    mov     eax, 0x10000
    mov     ebx, 512
    mov     ecx, (1 + 64)
    call    load_sector
    jc      error

    mov     si, OFFSET load_done_string
    call    print_string
    mov     si, OFFSET load_nl_string
    call    print_string
    call    print_string
    jmp     stage2_enter_protected

error:
    mov     si, OFFSET load_fail_string
    call    print_string

end:
    hlt
    jmp     end

# EAX: Base address of the load target
# EBX: Number of sector to load
# ECX: Start Sector
.globl load_sector
load_sector:
    push    ebp
    mov     bp, sp
    push    esi
    push    edx

    push    eax  # bp - 12
    push    ebx  # bp - 16
    push    ecx  # bp - 20

loop:
    # load ebx
    test    ebx, 64
    jae     more_than64
    mov     DWORD PTR [bp - 16], 0
    jmp     calc_start_sector

more_than64:
    mov     ebx, 64
    sub     DWORD PTR [bp - 16], 64

calc_start_sector:
    mov     ecx, DWORD PTR [bp - 20]
    add     DWORD PTR [bp - 20], ebx

    # Store info into dab
    mov     WORD PTR [dab_num_sectors], bx
    mov     DWORD PTR [dab_start_block], ecx

    # calculate target address
    mov     eax, DWORD PTR [bp - 12]
    mov     ecx, ebx
    shl     ecx, 9      # ecx * 512
    add     DWORD PTR [bp - 12], ecx
    shr     eax, 4
    mov     WORD PTR [dab_target_seg], ax

    mov     dx, [drive_number]
    mov     si, offset disk_address_block
    mov     ah, 0x42
    int     0x13
    jc      load_sector_end     # fail

    mov     ebx, DWORD PTR [bp - 16]
    test    ebx, ebx
    jnz     loop
    xor     eax, eax # success

load_sector_end:
    pop     ecx
    add     sp, 4   # skip eax
    pop     ebx
    pop     edx
    pop     esi
    pop     ebp
    ret

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

.align 8
disk_address_block:
    .byte       0x10        # length of this block
    .byte       0x0         # reserved
dab_num_sectors:
    .short      0           # max 64
dab_target_addr:
    .short      0           # Target memory address
dab_target_seg:
    .short      0
dab_start_block:
    .quad       0           # Starting Disk block 1, since we just need to skip the boot sector.

loading_string:
    .ascii "In Stage 2\r\n"
    .byte 0

load_fail_string:
    .ascii "Failed to load kernel"
    .byte 0

load_done_string:
    .ascii "Done"
    .byte 0

load_nl_string:
    .ascii "\r\n "
    .byte 0

.align 4
drive_number:
    .long 0
