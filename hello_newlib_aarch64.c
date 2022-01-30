#include <stdint.h>
#include <string.h>

/* QEMU virt machine memory map sets VIRT_UART as 0x90000000 */
#define UART0_BASE 0x09000000	 /* Same as Data Register, 12/8 width */
#define UART0_BASE_FR 0x09000018 /* Flag Register Offset, 9 width*/
#define UART0_BASE_RSR_ECR 0x09000004 /* Receive Status / Error Clear Register Offset, 4/0 width width*/
#define FR_TXFF (1 << 5)	     /* Bit 6 from FR */
#define FR_RXFE (1 << 4)	     /* Bit 5 from FR */
#define DR_DATA_MASK (0xFF)	     /* 8 width */
#define RSRECR_ERR_MASK (0xF)	     /* 4 width */
#define BUFFER_SIZE 64		     /* Buffer to hold received data */

uint8_t read_uart0(char* c);
void putchar_uart0(char c);
void print_uart0(const char* str);
static void check_cmd(void);

volatile unsigned int * const UART0DR = (unsigned int *)UART0_BASE;
volatile unsigned int * const RSR_ECR = (unsigned int *)UART0_BASE_RSR_ECR;
volatile unsigned int * const FR = (unsigned int *)UART0_BASE_FR;

/* Get TX_full bit and send */
void putchar_uart0(char c) {
  while (*FR & FR_TXFF);
  *UART0DR = c;
}

/* Until we reach to the end of the string, put each char on UART0 */
void print_uart0(const char* str) {
  while (*str != '\0') {
    putchar_uart0(*str);
    str++;
  }
}

uint8_t read_uart0(char* c) {
  /* Have we received anything? */
  if (*FR & FR_RXFE) {
    return 1;
  }

  /* DR Register width is 12, mask it */
  *c = *UART0DR & DR_DATA_MASK;
  if (*RSR_ECR & RSRECR_ERR_MASK) {
    /* Get the error */
    *RSR_ECR &= RSRECR_ERR_MASK;
    return 1;
  }
  /* No Error */
  return 0;
}

char buffer[BUFFER_SIZE];  /* Character buffer */
uint8_t buffer_idx = 0;		/* Exactly 8 bits */

static void check_cmd(void) {
  if (!strncmp("Yocto\r", buffer, strlen("Yocto\r"))) {
    print_uart0("Welcome\n");
    /* Use ~ as a known behavior for testing purposes */
  } else if (!strncmp("?\r", buffer, strlen("?\r"))) {
    print_uart0("Success\n");
  } else {
    print_uart0("Unrecognized command\n");
  }
}


/* Entry function from startup.s */
void c_entry() {
  print_uart0("Hello OpenEmbedded!\n");
  while (1) {
    char c;
    if (read_uart0(&c) == 0) {
      /* echo it */
      putchar_uart0(c);
      buffer[buffer_idx++ % BUFFER_SIZE] = c;
      /* Have we reached a CR */
      if (c == '\r') {
	buffer_idx = 0u;
	check_cmd();
      }
    }
  }
}
