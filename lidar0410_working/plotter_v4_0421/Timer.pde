class Timer
{
  long startTime;
  // constructor, starts timer 
  Timer() {
    startTime = millis();
  }
  // get time passed from start
  long getTime() {
    return (millis()-startTime);
  }
  // restart timer
  void reset() {
    startTime = millis();
  }
}