# Based on https://github.com/Codetector1374/GuideOS (no license specified)
# Avoid enabling A20 gate via the 8042 keyboard controller

.intel_syntax noprefix

.extern c_entry
.globl _start
.globl raw_entry


# Magic for when we use multiboot
.code32
.section .raw_init, "ax"
raw_entry:
    mov     eax, 0xb0bacafe
    mov     ebx, 0
    jmp     _start

.section .bootstrap, "ax"
.align 8
_start:
    cli
    mov esp, 0x80000
    push ebx
    push eax

# Enable CR4.PAE bit
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

# Set IA32_EFER.LME (EFER MSR, Long Mode Enable)
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

# Build Page Tables
    mov eax, OFFSET pdp
    or eax, 0b11
    mov [pml4], eax
    mov [pml4 + (256 * 8)], eax

# Load CR3 (PTBR) with PML4 physical address
    mov eax, OFFSET pml4
    mov cr3, eax

# Set CR0.PG (Paging Enable)
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

# Load new GDT and long jump to update CS (code segment selector)
    lgdt    [gdtdesc]
    jmp     0x8:long_start

# Long mode
.code64

long_start:
    mov     ax, 0x10
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     fs, ax
    mov     gs, ax

    mov     rax, 0xFFFF800000000000
    add     rax, OFFSET gdt64
    mov     [gdtdesc_addr], rax
    movabs  rax, OFFSET gdtdesc
    mov     rcx, 0xFFFF800000000000
    add     rax, rcx
    lgdt    [rax]

    mov     rdi, DWORD [rsp]
    mov     rsi, DWORD [rsp + 4]
    mov     rbp, 0xFFFFFFFFFFFFFFFF
    mov     rsp, 0xFFFF800000000000 + 0x80000

    movabs  rax, OFFSET c_entry
    call    rax

halt:
    hlt
    jmp halt

gdt64:
    # Null Entry
    .quad   0

    .quad (1<<53) | (1<<47) | (1<<44) | (1<<43) # Flags:L, Access: P, Access: S, Access: E

    .quad (1<<53) | (1<<47) | (1<<44) | (1<<41) # Flags:L, Access: P, Access: S, Access: RW

gdtdesc:
    .short   (gdtdesc - gdt64 - 1)
gdtdesc_addr:
    .quad   gdt64

.section .bootstrap.data, "wa"
.align 4096
pml4:
.fill 512, 8, 0

.align 4096
pdp:
.quad (0x80 | 0x2 | 0x1)
.fill 511, 8, 0
