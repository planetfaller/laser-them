void readDistance(boolean biasMode) {

  // Write to register 0x00 setting mode biased/corrected
  Wire.beginTransmission(addr);
  Wire.write(0x00);

  if (biasMode == true) {
    Wire.write(0x04); // bias corrected
  }
  else {
    Wire.write(0x03); // biased
  }

  Wire.endTransmission();

  //Begin measurement
  
  Wire.beginTransmission(addr);
  Wire.write(0x01);
  
  //Write last measurements bytes Serial
  printToSerial();

  if (interruptToggled){
  // calculate difference from last zero crossing and convert to seconds
  unsigned long zCTDiff = zCTime - lZCTime;
  rFreq = 1/((zCTDiff)/1000000.0); // rotFreq gets calculated and stored

  lZCTime = zCTime;
  // escUpdate();
  
  float error = setVal - rFreq;
  errorSum = error + errorSum;
  escSpeed = (int)(escSpeed + error*kp + 0.05*errorSum);
 //  Serial.println(escSpeed);
  if(escSpeed > 1600 || escSpeed < 1000){
    escSpeed = 1600;
  }
  esc.write(escSpeed);
  interruptToggled = false;
  }



  // write to 0x01, read one byte, break out when LSB is 0
  do {
    Wire.requestFrom(addr, 1);
    confirmByte = Wire.read();
    Wire.beginTransmission(addr);
    Wire.write(0x01);
  } while (confirmByte & 1); // wait for LIDAR to complete reading


  // read two bytes from 0x8f when reading is confirmed

  Wire.beginTransmission(addr);
  Wire.write(0x8f);
  Wire.endTransmission();
  Wire.beginTransmission(addr);
  Wire.requestFrom(addr, 2);
  byte byteOne = Wire.read();
  byte byteTwo = Wire.read();

  storedDist = (byteOne << 8) + byteTwo; // shift first byte left and concatenade
  
  Wire.endTransmission();
}

