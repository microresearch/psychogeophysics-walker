#include "WProgram.h"
#line 1 "servotest.pde"
#include <MegaServo.h>
#define NBR_SERVOS 1  // the number of servos, up to 48 for Mega, 12 for other boards
#define FIRST_SERVO_PIN 2 

MegaServo Servos[NBR_SERVOS] ; // max servos is 48 for mega, 12 for other boards

int pos = 0;      // variable to store the servo position 
int potPin = 0;   // connect a pot to this pin.

void setup()
{

  Serial.begin(9600);
  for( int i =0; i < NBR_SERVOS; i++)
    Servos[i].attach( FIRST_SERVO_PIN +i, 800, 2200);
}
void loop()
{ 

  pos=pos%148; // adjust for fingers
  
  if (Serial.available() > 0) {
    // read the incoming byte:
    pos = (100+(Serial.read()%80));
  }

  //  pos++;

  //  pos=140; // adjust for fingers


  for( int i =0; i <NBR_SERVOS; i++) 
    Servos[i].write(pos);   
    delay(1);   
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

