  
void simData() {
  for(int i=0; i < 360; i++){
    
  Serial.print(random(350,400)); // WORD 2 BYTE
  Serial.print('@'); // CHAR 1 BYTE
  Serial.print(i); // WORD 2 BYTE
  Serial.print('@'); // CHAR 1 BYTE
  Serial.print(random(1200,1300)); // UNSIGNED INT 2 BYTE
  Serial.print(','); // CHAR 1 BYTE
  delay(5);
  }
}
