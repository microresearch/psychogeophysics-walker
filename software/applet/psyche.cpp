#include "WProgram.h"
#line 1 "psyche.pde"
/* psyche board functions for arduino:

gsr-average
imp - see 5933.pde
temperature - below

*/

// first- test temperature
#include <OneWire.h>
#include <DallasTemperature.h>
 
#define ONE_WIRE_BUS 2
 
OneWire oneWire(ONE_WIRE_BUS);
 
DallasTemperature sensors(&oneWire);
DallasTemperature setWaitForConversion(false);
 
void setup(void)
{
  Serial.begin(9600);
  sensors.begin();
}
 
 
void loop(void)
{
  //  sensors.requestTemperatures();

  // delay here - do otherstuff
  // read/average? GSR + read AD5933

  //  Serial.print(sensors.getTempCByIndex(0));
  //  Serial.print(", ");
  Serial.print("TeST");


  // but should print as one collected buffer...
 
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

