/*
 * Print to serial. Handle serial com. here.
 * 
 */


void printToSerial() {
  //  Serial.write(highByte(storedDist));
  //  Serial.write(lowByte(storedDist));
  //  Serial.write(highByte(storedLoc));
  //  Serial.write(lowByte(storedLoc));

  String toPrint = String(storedDist, DEC) + "&" + String(storedLoc, DEC);// +  "&" + String(rotFreq, 2)+  "&" + String(mFreq, 2) + "&" + mCount;
  Serial.println(toPrint);
}
