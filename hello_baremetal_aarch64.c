/* QEMU virt machine memory map sets VIRT_UART as 0x90000000 */
#define UART0_BASE 0x09000000

volatile unsigned int * const UART0DR = (unsigned int *)UART0_BASE;

/* Until we reach to the end of the string, put each char on UART0 */
void print_uart0(const char *str) {
  while(*str != '\0') {
    *UART0DR = (unsigned int)(*str);
    str++;
  }
}

/* Entry function from startup.s */
void c_entry() {
  print_uart0("Hello OpenEmbedded on ARM64!\n");
}
