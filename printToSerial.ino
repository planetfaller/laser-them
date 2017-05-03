/*
 * Print to serial. Handle serial com. here.
 * 
 */


void printToSerial() {
  String toPrint;
  toPrint = String(storedDist, DEC)+",";
  // toPrint = String(rFreq, 2);
  
  if (counter>1){
    //Serial.flush();
    Serial.println(toPrint);
  // Serial.print(String(timerOne.getTime(), DEC) + ","); // debug
  }
}
