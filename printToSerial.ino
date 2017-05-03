/*
 * Print to serial. Handle serial com. here.
 * 
 */


void printToSerial() {
  String toPrint;
  toPrint = String(storedDist, DEC)+",";
  if (counter>1){
    Serial.print(toPrint);
  // Serial.print(String(timerOne.getTime(), DEC) + ","); // debug
  }
}
