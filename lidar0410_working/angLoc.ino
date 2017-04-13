/*
 * Print to serial. Handle serial com. here.
 * 
 */

void angLoc() {
  storedLoc = 360*rotFreq*((micros() - zeroCrossingTime)/1000000.0); // angular location measurement
}
