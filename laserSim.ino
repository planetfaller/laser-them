void setup() {
  Serial.begin(115200);
}

void loop() {
  for(int i=0; i < 360; i++){
    String toPrint = String(random(100,400), DEC) + "," + String(i, DEC);// +  "&" + String(rotFreq, 2)+  "&" + String(mFreq, 2) + "&" + mCount;
  Serial.println(toPrint);
  delay(1);
  }
}
