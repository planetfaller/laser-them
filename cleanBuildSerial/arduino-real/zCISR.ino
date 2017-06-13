/**
  ISR Routine for external interrupt by hall sensor
  
  @return void
*/

void zCISR() {
  zCTime = micros(); // save current time (takes approx 3.75 us)
  interruptToggled = true; // notice for main that an interrupt has happened
}
