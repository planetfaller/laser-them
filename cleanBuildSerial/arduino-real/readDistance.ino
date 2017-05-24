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

  // update rotation speed/position and ESC

  if (interruptToggled) {
    angVelFun(); // call to update
    // escUpdate(); // call to update speed
    interruptToggled = false; // we dealt with interrupt
  }

  // write to 0x01, read one byte, break out when LSB is 0
  do {
    Wire.requestFrom(addr, 1);
    confirmByte = Wire.read();
    Wire.beginTransmission(addr);
    Wire.write(0x01);
  } while (confirmByte & 1); // wait for LIDAR to complete reading

  timestamp = micros(); // collect timestamp
  timeDiff = timestamp - lastTimeStamp;
  lastTimeStamp = timestamp;


  angPosFun(); // call to update angular position



  // read two bytes from 0x8f when reading is confirmed

  Wire.beginTransmission(addr);
  Wire.write(0x8f);
  Wire.endTransmission();
  Wire.beginTransmission(addr);
  Wire.requestFrom(addr, 2);
  byte byteOne = Wire.read();
  byte byteTwo = Wire.read();

  distance = (byteOne << 8) + byteTwo; // shift first byte left and concatenade

  Wire.endTransmission();
}

