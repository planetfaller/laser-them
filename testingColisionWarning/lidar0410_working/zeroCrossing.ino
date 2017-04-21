void zeroCrossing() {
  zeroCrossingTime = micros(); // zero crossing gets timestamped
  // calculate difference from last zero crossing and convert to seconds
  unsigned long timeDiff = zeroCrossingTime - lastZeroCrossingTime;
  // angFreqStored = (1/(timeDiff))*2*pi; // calculating angular speed // ang speed in radians
  rotFreq = 1/((timeDiff)/1000000.0); // rotFreq gets calculated and stored
  lastZeroCrossingTime = zeroCrossingTime; // store time for next lap
}
