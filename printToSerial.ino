/*
 * Print to serial. Handle serial communication here.
 * 
 */


void printToSerial() {
  String toPrint;
  Serial.print(distance); // WORD 2 BYTE
  Serial.print('D'); // CHAR 1 BYTE
  Serial.print(angPos); // WORD 2 BYTE
  Serial.print('P'); // CHAR 1 BYTE
  Serial.print(timeDiff); // UNSIGNED INT 2 BYTE
  Serial.println('T'); // CHAR 1 BYTE
}
