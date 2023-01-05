/*
 Based on multiboot header available at https://intermezzos.github.io/book/first-edition/multiboot-headers.html
*/
        .section multiboot
        .align 4
header_start:
        .long 0xe85250d6                /* Multiboot2 magic number */
        .long 0                         /* protected mode code on i386 */
        .long header_end - header_start /* header length */

        /* checksum */
        .long -(0xe85250d6 + 0 + (header_end - header_start))

        /* required end tag */
        .word 0    /* type */
        .word 0    /* flags */
        .long 8    /* size */
header_end:
