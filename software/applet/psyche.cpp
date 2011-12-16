#include "WProgram.h"
#line 1 "psyche.pde"
/* psyche board functions for arduino

- added PD7 = pin 7 for flashing -> GND

*/

#include <OneWire.h>
#include <Wire.h>
 
#define STARTFREQ 10000 // 10 KHz

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

void read_control_register_MSB(void);

OneWire  ds(8);
byte i;
byte present = 0;
byte data[12];
byte addr[8];

int HighByte, LowByte, SignBit, Whole, Fract, TReading, Tc_100, FWhole;

int z,cnt;
int strFreqMMSB = 0x00; //Start Frequency MMSB - Reg. 0x82
int strFreqMSB = 0x7D; //Start Frequency MSB - Reg. 0x83
int strFreqLSB = 0x00; //Start Frequency LSB - Reg. 0x84 // 32KHz? but seems to be 1 KHz??

// so we need to do freqcode=startfreq*33.554432;

int stpFreqMMSB = 0x00; //Step Frequency MMSB - Reg. 0x85
int stpFreqMSB = 0x18; //Step Frequency MSB - Reg. 0x86
int stpFreqLSB = 0x38; //Step Frequency LSB - Reg. 0x87

int stpNumMSB = 0x01; //Step Number MSB - Reg. 0x88
int stpNumLSB = 0xFF; //Step Number LSB - Reg. 0x89

int setNumMSB = 0x00; //Settling Number MSB - Reg. 0x8A 

int setNumLSB = 0x10; //Settling Number LSB - Reg. 0x8B - was 0x10

int ctrlRegMapMSB;
int ctrlRegMapLSB;

unsigned long int fft_real_data; //AD5933 FFT Real Data value
unsigned long int fft_img_data; //AD5933 FFT Inaginary Data value
unsigned long int magn, freqcode;

void get_real_img_data()
{
/* ----------------------- FFT Real Data MSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x94); // sets register pointer to FFT Real Data
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x94

if(1 <= Wire.available()) // if one byte is received
{
fft_real_data = Wire.receive(); // receive high byte (overwrites previous reading)
fft_real_data = fft_real_data << 8; // shift high byte to be high 8 bits
}

/* ----------------------- FFT Real Data LSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x95); // sets register pointer to FFT Real Data
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x95

if(1 <= Wire.available()) // if one byte is received
{
fft_real_data |= Wire.receive(); // receive low byte as lower 8 bits*/
}

/* ----------------------- FFT Imaginary Data MSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x96); // sets register pointer to FFT Img Data
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x96

if(1 <= Wire.available()) // if one byte is received
{
fft_img_data = Wire.receive(); // receive high byte (overwrites previousreading)
fft_img_data = fft_img_data << 8; // shift high byte to be high 8 bits
}

/* ----------------------- FFT Imaginary Data LSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x97); // sets register pointer to FFT Img Data
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x97

if(1 <= Wire.available()) // if one byte is received
{
fft_img_data |= Wire.receive(); // receive low byte as lower 8 bits*/
}

/* ----------------------- 2's complement to decimal conversion
-------------------- */
// The Real data is stored in a 16 bit 2's complement format.
// In order to use this data it must be converted from 2's complement to decimal format

/*if (fft_real_data <= 0x7FFF) // h7fff 32767
{
// fft_real_data = fft_real_data & 0x7FFF; // Less than or equal to 32767, leave unchanged
}
else
{
  fft_real_data = fft_real_data & 0x7FFF; // Greater than 32767
  fft_real_data = fft_real_data - 65536;
*/
if(fft_real_data > 0x7fff)
{
fft_real_data=0x10000-fft_real_data;
}

if(fft_img_data > 0x7fff)
{
fft_img_data=0x10000-fft_img_data;
}


//}

/*if (fft_img_data <= 0x7FFF) // h7fff 32767
{
// fft_img_data = fft_img_data & 0x7FFF; // Less than or equal to 32767,leave unchanged
}
else
{
fft_img_data = fft_img_data & 0x7FFF; // Greater than 32767
fft_img_data = fft_img_data - 65536;*/


}

//}

void load_start_frequency()
{
//-------------------------------- Load Start Frequency
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x82); // sets register pointer to Start Frequency MMSB Register(0x82)
Wire.send(strFreqMMSB); // Start Frequency MMSB - Reg. 0x82
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x83); // sets register pointer to Start Frequency MSB Register(0x83)
Wire.send(strFreqMSB); // Start Frequency MSB - Reg. 0x83
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x84); // sets register pointer to Start Frequency LSBRegister(0x84)
Wire.send(strFreqLSB); // Start Frequency LSB - Reg. 0x84
Wire.endTransmission(); // stop transmitting

}

void load_frequency_increment()
{
//-------------------------------- Load Frequency Increment amount
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x85); // sets register pointer to Frequency Increment MSBRegister(0x85)
Wire.send(stpFreqMMSB); // Step Frequency MMSB - Reg. 0x85
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x86); // sets register pointer to Frequency Increment xMSBRegister(0x86)
Wire.send(stpFreqMSB); // Step Frequency MSB - Reg. 0x86
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x87); // sets register pointer to Frequency Increment LSBRegister(0x87)
Wire.send(stpFreqLSB); // Step Frequency LSB - Reg. 0x87
Wire.endTransmission(); // stop transmitting
}

void load_increment_number()
{
//-------------------------------- Load Number of Frequency Increments
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x88); // sets register pointer to Number of FrequencyIncrements MSB Register(0x88)
Wire.send(stpNumMSB); // Step Number MSB - Reg. 0x88
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x89); // sets register pointer to Number of FrequencyIncrements LSB Register(0x89)
Wire.send(stpNumLSB); // Step Number LSB - Reg. 0x89
Wire.endTransmission(); // stop transmitting
}

void load_settling_time()
{
//-------------------------------- Load Settling Time---------------------------------
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x8A); // sets register pointer to Settling Time MSBRegister(0x8A)
Wire.send(setNumMSB); // Settling Number MSB - Reg. 0x8A
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x8B); // sets register pointer to Settling Time LSBRegister(0x8B)
Wire.send(setNumLSB); // Settling Number LSB - Reg. 0x8B
Wire.endTransmission(); // stop transmitting
}

void initialize_frequency()
{
//-------------------------------- Place AD5933 in Initialize FrequencyMode ---------------------------------
read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D12 ofctrlRegMapMSB
ctrlRegMapMSB &= 0x0F; //clear xxxx yyyy 0000 1111 0x0F
ctrlRegMapMSB |= 0x10; //set yyyx yyyy 0001 0000 0x10

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void start_sweep()
{
//-------------------------------- Place AD5933 in Sweep Frequency Mode

read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D13 ofctrlRegMapMSB
ctrlRegMapMSB &= 0x0F; //clear xxxx yyyy 0000 1111 0x0F
ctrlRegMapMSB |= 0x20; //set yyxy yyyy 0010 0000 0x20

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void increment_frequency()
{
//-------------------------------- Place AD5933 in Step Frequency Mode---------------------------------
read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D13,D12 ofctrlRegMapMSB
ctrlRegMapMSB &= 0x0F; //clear xxxx yyyy 0000 1111 0x0F
ctrlRegMapMSB |= 0x30; //set yyxx yyyy 0011 0000 0x30

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void repeat_frequency()
{
//-------------------------------- Place AD5933 in Repeat Frequency Mode
read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D13, Clear D12 ofctrlRegMapMSB
ctrlRegMapMSB &= 0x0F; //clear xxxx yyyy 0000 1111 0x0F
ctrlRegMapMSB |= 0x40; //set yxyy yyyy 0100 0000 0x40

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void AD5933_standby()
{
//-------------------------------- Place AD5933 in Standby Mode---------------------------------
read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D13, Clear D12 ofctrlRegMapMSB
ctrlRegMapMSB &= 0x0F; //clear xxxx yyyy 0000 1111 0x0F
ctrlRegMapMSB |= 0xB0; //set xyxx yyyy 1011 0000 0xB0

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void AD5933_out_amp_1()
{
//-------------------------------- Set AD5933 Output Amplitude to 1.0 VP-P ---------------------------------
read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D10,D9 ofctrlRegMapMSB
ctrlRegMapMSB &= 0xF9; //clear yyyy yxxy 1111 1001 0xF9
ctrlRegMapMSB |= 0x06; //set yyyy yxxy 0000 0110 0x06

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x81)
// ctrlRegMapMSB=0x06;
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void AD5933_pgaX1()
{
//-------------------------------- Place AD5933 in PGA X1 Mode---------------------------------
read_control_register_MSB(); //Get AD5933 Reg. 0x80 value into ctrlRegMapMSB
//Set D8 ofctrlRegMapMSB
// ctrlRegMapMSB &= 0x0F; //clear xxxx yyyy 0000 1111 0x0F
ctrlRegMapMSB |= 0x01; //set yyyy yyyx 0000 0001 0x01

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.send(ctrlRegMapMSB); //
Wire.endTransmission(); // stop transmitting
}

void AD5933_reset()
{
//-------------------------------- Place AD5933 in Reset Mode---------------------------------
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x81); // sets register pointer to Control LSB Register(0x80)
ctrlRegMapLSB=0x10; // Reset Hi
Wire.send(ctrlRegMapLSB); //
Wire.endTransmission(); // stop transmitting

Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0x81); // sets register pointer to Control LSB Register(0x80)
ctrlRegMapLSB=0x00; // Reset Lo
Wire.send(ctrlRegMapLSB); //
Wire.endTransmission(); // stop transmitting
}

void read_control_register_MSB()
{
/* ----------------------- Read AD5933 Control Register MSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x80); // sets register pointer to Control MSB Register(0x80)
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x80

if(1 <= Wire.available()) // if one byte is received
{
ctrlRegMapMSB = Wire.receive();
}
}

void read_control_register_LSB()
{
/* ----------------------- Read AD5933 Control Register LSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x81); // sets register pointer to Control LSB Register(0x81)
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x81

if(1 <= Wire.available()) // if one byte is received
{
ctrlRegMapLSB = Wire.receive();
}
}

int read_status_register()
{
/* ----------------------- Read AD5933 Control Register MSB
------------------------------ */
Wire.beginTransmission(0x0D); // transmit to device 0x0D (AD5933)
Wire.send(0xB0); // sets register pointer command (0xB0)
Wire.send(0x8F); // sets register pointer to Status MSB Register(0x8F)
Wire.endTransmission(); // stop transmitting

Wire.requestFrom(0x0D, 1); // request 1 byte from slave device 0x0D(AD5933) register 0x8F

if(1 <= Wire.available()) // if one byte is received
{
z = Wire.receive();
}
 return z;
//Serial.print(byte(z)); // Send to USB
}

void getTemp() {
  int foo, bar;
  
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);
  
  present = ds.reset();
  ds.select(addr);    
  ds.write(0xBE);

  for ( i = 0; i < 9; i++) {
    data[i] = ds.read();
  }
  
  LowByte = data[0];
  HighByte = data[1];
  TReading = (HighByte << 8) + LowByte;
  SignBit = TReading & 0x8000;  // test most sig bit
  
  if (SignBit) {
    TReading = -TReading;
  }

  TReading &= 0xfffe;
  TReading <<=3;
  TReading += (16 - data[6]) - 4;

  Whole  = (uint8_t)(TReading >> 4); 
  Fract = (uint8_t)(TReading & 0x000F);


  /*  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25
  Whole = Tc_100 / 100;          // separate off the whole and fractional portions
  Fract = Tc_100 % 100;
  if (Fract > 49) {
    if (SignBit) {
      --Whole;
    } else {
      ++Whole;
 }
  */

}

 
void setup(void)
{
  Serial.begin(57600);
  Wire.begin();
  sbi(ADCSRA,ADPS2) ;
  cbi(ADCSRA,ADPS1) ;
  cbi(ADCSRA,ADPS0) ;

  freqcode=335544; // hardcoded!
//calculate the hex frequency *code*
strFreqMMSB=0x000000ff & (freqcode>>16); 
strFreqMSB=0x000000ff &(freqcode>>8); 
strFreqLSB=0x000000ff & freqcode;

  AD5933_reset(); 
  AD5933_standby();
  AD5933_out_amp_1();
  AD5933_pgaX1();

  load_start_frequency();
  load_frequency_increment();
  load_increment_number();
  load_settling_time();
  initialize_frequency();

  pinMode(7, OUTPUT);
  ds.search(addr);
 }


 void loop(void)
 {
   float temp;
   long gsr; // gsr is on ADC0

   // BELOW should be in ad5933 loop somehow

      start_sweep();  

      while(!(read_status_register() & 0x04)) {   //- check status reg to see if sweep complete

      while(!(read_status_register() & 0x02));  //- check status reg to see if dft complete

   //- read real/imag and print with frequency
      get_real_img_data();
   //  Serial.print("real: ");
   //  Serial.print(fft_real_data);

   //  Serial.print(" image: ");

   //magn+=sqrt(fft_real_data*fft_real_data+fft_img_data*fft_img_data);
   //   magn+=fft_real_data*fft_real_data; // not enough space for sqrt
     cnt++;

     if (cnt>4){
     gsr += analogRead(0);
     fft_real_data=fft_real_data/4;
     fft_img_data=fft_img_data/4;
     gsr=gsr/4; // average
   Serial.print("p: ");
     
   Serial.print(fft_real_data);
   Serial.print(", ");
   Serial.print(fft_img_data);
   Serial.print(", ");
   getTemp();
   Serial.print(Whole);
   Serial.print(".");
   Serial.print(Fract);
   Serial.print(", ");
   Serial.print(gsr);
   Serial.print("\r\n");

   // flash pin 7 = pD7

   PORTD ^= 128;

     }
  gsr=0;
  // but should print as one collected buffer...???
  repeat_frequency();
 }
 }
#line 1 "/root/olderprojects/dump/arduino-0016//hardware/cores/arduino/main.cxx"
int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

