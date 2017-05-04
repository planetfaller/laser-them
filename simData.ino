  
void simData() {
  for(int i=0; i < 360; i++){
    String toPrint = String(random(100,400), DEC) + "," + String(i, DEC);// +  "&" + String(rotFreq, 2)+  "&" + String(mFreq, 2) + "&" + mCount;
  Serial.print(random(100,400)); // WORD 2 BYTE
  Serial.print('@'); // CHAR 1 BYTE
  Serial.print(i); // WORD 2 BYTE
  Serial.print('@'); // CHAR 1 BYTE
  Serial.print(random(1200,1300)); // UNSIGNED INT 2 BYTE
  Serial.print(','); // CHAR 1 BYTE
  delay(1);
  }
}
