/*
 * Print to serial. Handle serial com. here.
 * 
 */


void printToSerial() {
  String toPrint;
  toPrint = String(storedDist, DEC)+","; // concatenating stuff to print
  Serial.print(toPrint);
  // Serial.print(String(timerOne.getTime(), DEC) + ","); // debug
}
