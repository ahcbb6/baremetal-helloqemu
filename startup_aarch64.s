/* Declare the _start symbol as global */
.globl _start
_start:
        /* No main function, jump to c_entry
        as the beginning of our program */
        ldr x29, =stack_top
        mov sp, x29
        bl c_entry
        b .
