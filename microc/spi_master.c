/* MEGA8 test for spi communication and FGM-3 connection */
/* this is the SPI master which will get data from FGM-slave */
/* and send via serial as a testbed */

#define F_CPU 12000000UL  // 12 MHz

#include <avr/io.h>
#include <stdio.h>
#include <inttypes.h>
#include <avr/delay.h>

#define UART_BAUD_CALC(UART_BAUD_RATE,F_OSC) ((F_OSC)/((UART_BAUD_RATE)*16l)-1)

void delay(int ms){
	while(ms){
		_delay_ms(0.96);
		ms--;
	}
}

void serial_init(int baudrate){
  UBRRH = (uint8_t)(UART_BAUD_CALC(baudrate,F_CPU)>>8);
  UBRRL = (uint8_t)UART_BAUD_CALC(baudrate,F_CPU); /* set baud rate */
  UCSRB = (1<<RXEN) | (1<<TXEN); /* enable receiver and transmitter */
  UCSRC = (1<<URSEL) | (3<<UCSZ0);   /* asynchronous 8N1 */
}

static int uart_putchar(char c, FILE *stream);

static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL,_FDEV_SETUP_WRITE);

static int uart_putchar(char c, FILE *stream)
{
  loop_until_bit_is_set(UCSRA, UDRE);
  UDR = c;
  return 0;
}
