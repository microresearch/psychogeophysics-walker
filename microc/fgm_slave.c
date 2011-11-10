/* MEGA8 test for spi communication and FGM-3 connection */
/* this is the SPI slave */

#define F_CPU 12000000UL  // 12 MHz

#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdio.h>
#include <inttypes.h>
#include <avr/delay.h>

/* frequency count 1st FGM */

unsigned int fc_dur;
unsigned long Freq;
volatile unsigned char low;
volatile unsigned int FreqCount, count;

ISR(INT0_vect) {
  if ((PIND & (1<<2)) == 4) count++; //PD2 as INT0 PIN
}

ISR(TIMER1_COMPA_vect)	
{
  FreqCount = count;
  count=0;
}


void WriteByteSPI(unsigned char byte)
{
  SPDR = byte;					//Load byte to Data register
  while(!(SPSR & (1<<SPIF))); 	// Wait for transmission complete 
}

void InitSPI(void)
{
  DDRD = 0x08;
  DDRB = (1<<PB4);	 // Set MISO as OUT
  SPCR = ( (1<<SPE)|(1<<SPR1) |(1<<SPR0)|(1<<CPHA));//|(1<<SPIE));	// Enable SPI, Slave, set clock rate fck/128  
}

void delay(int ms){
  while(ms){
    _delay_ms(0.96);
    ms--;
  }
}

void main() {
  unsigned int count,y,z;
  unsigned char inbetween;
  unsigned int data;
  InitSPI();

  // set up timer
  fc_dur=8;
  OCR1A = 91; // let's say every second! now every 128th

  // TODO: enable interrupt on INT0 (and later on INT1)
  GICR |= _BV(INT0); 
  MCUCR |= (1<<ISC01);
  MCUCR |= (1<<ISC00); 

  TCCR1B |= (1 << WGM12);    // Mode 4, CTC on OCR1A
  TIMSK |= (1 << OCIE1A);     //Set interrupt on compare match
  TCCR1B |= (1 << CS12) | (1 << CS10);    // set prescaler to 1024 and starts the timer
  sei();

  while(1) {
    data=FreqCount;
    inbetween=(unsigned char)(data&0xff);
    WriteByteSPI(inbetween);
    inbetween=((unsigned int)(data)>>8)&0xff;
    WriteByteSPI(inbetween);
  }
}
