void escUpdate() {
  float error = setVal - angVel;
  errorSum = error + errorSum;
  escSpeed = (int)(escSpeed + error * kp + 0.05 * errorSum);
  //Serial.println(escSpeed);
  if (escSpeed > 1600 || escSpeed < 1000) {
    escSpeed = 1600;
  }
  esc.write(escSpeed);
}
