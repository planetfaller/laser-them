/**
  Initializes a new measurement to be made by Lidar Lite 3. While
  waiting for measurement to be completed the result of previous measurement
  is printed to serial. 
  
  @param boolean biasMode mode to make measurement in (true for bias mode)
  @return void
*/

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

  // begin measurement
  Wire.beginTransmission(addr);
  Wire.write(0x01);

  // write last measurements bytes Serial
  printToSerial();

  // update rotation speed/position and ESC
  if (interruptToggled) {
    angVelFun(); // call to update
    // escUpdate(); // call to update speed not used
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
  timeDiff = timestamp - lastTimeStamp; // calculate time difference
  lastTimeStamp = timestamp; // this time stamp is last time stamp

  angPosFun(); // call to update angular position

  // read two bytes from 0x8f when reading is confirmed
  Wire.beginTransmission(addr);
  Wire.write(0x8f);
  Wire.endTransmission();
  Wire.beginTransmission(addr);
  Wire.requestFrom(addr, 2);
  byte byteOne = Wire.read();
  byte byteTwo = Wire.read();

  distance = (byteOne << 8) + byteTwo; // shift first byte left and concatenate

  Wire.endTransmission(); // end i2c transmission
}

