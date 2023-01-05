#include <stdint-gcc.h>

/* Legacy COM1 I/O port address is 0x3f8 */
#define UART0_BASE 0x3f8

/* Use ASM outb for I/O writing into the serial port */
static inline void outb(uint16_t port, uint8_t data)
{
  __asm__ volatile("out %0,%1" : : "a" (data), "d" (port));
}

void uart_putchar(const char ch)
{
  outb(UART0_BASE, ch);
}

/* Until we reach to the end of the string, put each char on UART0 */
void print_uart0(const char *str) {
  while(*str != '\0') {
    uart_putchar(*str);
    str++;
  }
}

void c_entry()
{
  uart_putchar('\n');
  print_uart0("Hello OpenEmbedded on x86-64!\n");
  for (;;) {
  }
}
