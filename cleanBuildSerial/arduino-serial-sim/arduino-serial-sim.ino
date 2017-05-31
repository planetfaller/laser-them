int delayMS = 1; // delay in ms

void setup() {
  Serial.begin(115200);
}

void loop() {
  // serial simulator, matches v1@v2@v3,

  for (int i = 0; i < 360; i++) {
    String toPrint = String(random(380, 400), DEC) + "@" + String(i, DEC) + "@" + delayMS * 1000 + ","; //
    Serial.print(toPrint);
    delay(delayMS);
  }
}

