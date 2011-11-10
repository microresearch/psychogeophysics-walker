/* MEGA8 test for spi communication and FGM-3 connection */
/* this is the SPI master which will get data from FGM-slave */
/* and send via serial as a testbed */

#define F_CPU 12000000UL  // 12 MHz

#include <avr/io.h>
#include <stdio.h>
#include <inttypes.h>
#include <avr/delay.h>

#define UART_BAUD_CALC(UART_BAUD_RATE,F_OSC) ((F_OSC)/((UART_BAUD_RATE)*16l)-1)

void InitSPI(void)
{
  DDRB = (1<<PB3)|(1<<PB5) | (1<<PB0) | (1<<PB2);	 // Set MOSI , SCK , SS /SS output=pin14 PB0
 SPCR = ( (1<<SPE)|(1<<MSTR) | (1<<SPR1) |(1<<SPR0))|(1<<CPHA);	// Enable SPI, Master, set clock rate fck/128  
 PORTB|=0x04;
}

char ReadByteSPI(void)
{
  unsigned char addr;
  PORTB &= ~(1<<PB0); //low
  SPDR=0x01; // dummy data
  while(!(SPSR & (1<<SPIF)));
  addr=SPDR;
  _delay_us(1);            
  PORTB |= (1<<PB0); // high
  return addr;
}

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

void main() {
  unsigned char d,dd;
  unsigned int count,x,y,z;
  unsigned long ttt, data;
  serial_init(9600);
  stdout = &mystdout;
  InitSPI();
  DDRD = 0x08;

  while(1) {

    PORTB &= ~(1<<PB0); //low
    SPDR=0x01;
    while(!(SPSR & (1<<SPIF)));
    ttt=(unsigned char)SPDR;
    _delay_us(100);
    SPDR=0x01;
    while(!(SPSR & (1<<SPIF)));
    ttt+=(unsigned int)(SPDR)<<8;
    PORTB |= (1<<PB0); // high
    printf("test: %ld\r\n",ttt);
    delay(100);
    PORTD ^=0x08; //flash 
  }
}
