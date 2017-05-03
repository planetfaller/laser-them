// simple timer. remember to start with reset().

class Timer
{
    unsigned long startTime;
    boolean timerOn;

    // constructor
  public:
    Timer() {
      startTime = micros();
      timerOn = false;
    }

    unsigned long getTime() {
      return (micros() - startTime);
    }

    void reset() {
      timerOn = false;
    }

    void start(){
      if (timerOn == false){
        startTime = micros();
        timerOn = true;
      }
    }

};

// create a timer
Timer timerOne;

// some other declarations


void setup() {

  Serial.begin(115200); // serial baud rate
  timerOne.start();
}

void loop() {

if (timerOne.getTime() > 1000){
 String toPrint = String(random(0,500), DEC);
  Serial.print(toPrint + ",");
  timerOne.reset();
  timerOne.start();
}


}
