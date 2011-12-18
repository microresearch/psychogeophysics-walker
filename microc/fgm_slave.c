/* MEGA8 test for spi communication and FGM-3 connection */
/* this is the SPI slave */

#define F_CPU 12000000UL  // 12 MHz

#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdio.h>
#include <inttypes.h>
#include <avr/delay.h>

/* frequency count 1st FGM */

unsigned long Freq;
volatile unsigned char low;
volatile unsigned int FreqCount, count, secondcount, secondfreq;

ISR(INT0_vect) {
  if ((PIND & (1<<2)) == 4) count++; //PD2 as INT0 PIN
}

ISR(INT1_vect) {
  if ((PIND & (1<<3)) == 8) secondcount++; //PD3 as INT1 PIN
}


ISR(TIMER1_COMPA_vect)	
{
  FreqCount = count;
  secondfreq=secondcount;
  count=0; secondcount=0;
}


void WriteByteSPI(unsigned char byte)
{
  SPDR = byte;					//Load byte to Data register
  while(!(SPSR & (1<<SPIF))); 	// Wait for transmission complete 
}

void InitSPI(void)
{
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
  unsigned char inbetween;
  unsigned long d1,d2,diff;
  InitSPI();

  // set up timer
  OCR1A = 91; // let's say every second! now every 128th of a second

  OCR1A = 11648;

  // TODO: enable interrupt on INT0 and INT1
  GICR |= (1<<INT0) | (1<<INT1); 
  MCUCR |= (1<<ISC01) | (1<<ISC00) | (1<<ISC11) | (1<<ISC10); 

  DDRD |= 128;

  TCCR1B |= (1 << WGM12);    // Mode 4, CTC on OCR1A
  TIMSK |= (1 << OCIE1A);     //Set interrupt on compare match
  TCCR1B |= (1 << CS12) | (1 << CS10);    // set prescaler to 1024 and starts the timer
  sei();

  while(1) {
    d1=FreqCount; d2=secondfreq;
    if (d1>d2) diff=d1-d2;
    else diff=d2-d1;

    //    diff=16578;

    inbetween=(unsigned char)(diff&0xff);
    WriteByteSPI(inbetween);
    inbetween=((unsigned int)(diff)>>8)&0xff;
    WriteByteSPI(inbetween);

    if (diff>0) PORTD ^= 128; // flash pd7
  }
}
