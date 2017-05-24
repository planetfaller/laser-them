void angVelFun() {
  unsigned long zCTDiff = zCTime - lZCTime;
  angVel = 1 / ((zCTDiff) / 1000000.0); // rotFreq gets calculated and stored
  lZCTime = zCTime;
}
