
// ISR Routine, read micros() (approx 3.75 us)

void zCISR() {
  zCTime = micros(); // save current time
  interruptToggled = true; // notice for main that an interrupt has happened
}
