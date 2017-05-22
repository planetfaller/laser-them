/*
 * Print to serial. Handle serial communication here.
 * 
 */


void printToSerial() {
  String toPrint;
  Serial.print(distance); // WORD 2 BYTE
  Serial.print('@'); // CHAR 1 BYTE
  Serial.print(angPos); // WORD 2 BYTE
  Serial.print('@'); // CHAR 1 BYTE
  Serial.print(timeDiff); // UNSIGNED INT 2 BYTE
  Serial.print(','); // CHAR 1 BYTE
}
