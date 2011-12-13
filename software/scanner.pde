#include <Stepper.h>

# notes on attachment of motors

Stepper xaxis(100,30,32,34,36); //x motor - moving towards motor
Stepper yaxis(100,44,40,38,42); //y motor - moving towards motor

void setup() {
  xaxis.setSpeed(10);
  yaxis.setSpeed(10); 
  
  delay(100);

  // bring all motors to start!

}

void loop() {

  // start scan

//xaxis.step(1);
//delay(1);
}

