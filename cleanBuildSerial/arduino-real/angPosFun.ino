void angPosFun() {
  angPos = (360*angVel*((micros() - zCTime)/1000000.0)); // derive angular position and store
}
