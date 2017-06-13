/**
  Regulator function for speed controll. Not used in this version
  
  @return void
*/
void escUpdate() {
  float error = setVal - angVel; // calculate error term
  errorSum = error + errorSum; // calculate error sym
  escSpeed = (int)(escSpeed + error * kp + 0.05 * errorSum); // PI output
  if (escSpeed > 1600 || escSpeed < 1000) { // limit
    escSpeed = 1600; 
  }
  esc.write(escSpeed); // write speed output
}
