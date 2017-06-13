/**
  Derives the angular velocity based on time passed since
  last zero crossing
  
  @return void
*/

void angVelFun() {
  unsigned long zCTDiff = zCTime - lZCTime;
  angVel = 1 / ((zCTDiff) / 1000000.0); // rotFreq gets calculated and stored
  lZCTime = zCTime; // store this zero crossing time as last zero crossing time
}
