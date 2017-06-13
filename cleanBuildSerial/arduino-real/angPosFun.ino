/**
  Derives the angular position of the measurement based on time passed since
  last zero crossing and current angular velocity
  
  @return void
*/

void angPosFun() {
  angPos = (360 * angVel * ((micros() - zCTime) / 1000000.0)); // derive angular position and store
}
