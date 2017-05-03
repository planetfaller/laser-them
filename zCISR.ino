void zCISR(){
	
	zCTime = micros();
	 // calculate difference from last zero crossing and convert to seconds
  unsigned long zCTDiff = zCTime - lZCTime;
  rFreq = 1/((zCTDiff)/1000000.0); // rotFreq gets calculated and stored

	lZCTime = zCTime;
  // escUpdate();
  
  float error = setVal - rFreq;
  errorSum = error + errorSum;
  escSpeed = (int)(escSpeed + error*kp + 0.05*errorSum);
 //  Serial.println(escSpeed);
  if(escSpeed > 1500 || escSpeed < 1000){
    escSpeed = 1500;
  }
  esc.write(escSpeed);

}
