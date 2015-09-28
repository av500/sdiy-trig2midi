#ifndef _UART_H_
#define _UART_H_

#include "main.h"

#ifdef CONFIG_UART
#include "xprintf.h"
int  UART_init(void);
void UART_putc( unsigned char c);
int  UART_getc( void );
#define dbg xprintf

#else

#define UART_init(...)
#define dbg(...) 

#endif

#endif
