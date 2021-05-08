.equ STACK_SIZE, 1024
.equ STACK_SHIFT, 10
.equ HARTS, 4

/* Declare the _start symbol as global */
.global _start

_start:
    # Stack pointer needs to be based on hart (Hardware Thread) ID
    csrr t0, mhartid
    slli t0, t0, STACK_SHIFT
    la   sp, stacks + STACK_SIZE
    add  sp, sp, t0

    # Park all harts except ID=0
    csrr a0, mhartid
    bnez a0, park

    j c_entry

park:
    wfi
    j park

stacks:
    # Allocate stack for all harts
    .skip STACK_SIZE * HARTS
