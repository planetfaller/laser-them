// simple timer. remember to start with reset().

class Timer
{
    unsigned long startTime;
    boolean timerOn;

    // constructor
  public:
    Timer() {
      startTime = micros();
    }

    unsigned long getTime() {
      return (micros() - startTime);
    }

    void reset() {
      startTime = micros();
    }

};


//#include <SimpleFIFO.h> // Simple FIFO, used for buffer readings
#include <Wire.h> // Wire libary, to handle I2C
#include <Servo.h> // Servo library, for writing to ESC and controlling speed of motor 

#define addr 0x62 // I2C address to LIDAR
#define interruptPin 2 // interrupt for HALL sensor
#define escPin 6 // ESC for motor 

const float pi = 3.14; // PI
byte somethingRead[100];
byte byteOne, byteTwo;
int byteCon[100];
byte confirmByte = 255;
unsigned long timeList[100];
unsigned long thisTime=0;
unsigned long lastTime = 0; //For debugging
unsigned long highestTime = 0; //For debugging
//String tmpDist;
word tmpDist;
unsigned long timeDiffer;

int angOffset = 340;

byte dummyData[4];
int mCountToPrint;
int mCount=0;

unsigned long startTime = 1000;
float mFreq=0;
unsigned long lastLoopTime = 0;
unsigned long totalLoopTime;
int counter = 0;

Timer timerOne;
float rotFreq;
unsigned long zeroCrossingTime = 0;
unsigned long lastZeroCrossingTime = 0;
boolean lastBiasMode = false;
word storedDist;
word storedLoc;
boolean started = false;
boolean nmtStarted = false;

// using integers for storing readings, might want to use float

int angFreqStored;

// interrupt variables

volatile unsigned long zeroTime;
volatile boolean flag = false;

Servo esc;

void setup() {
  attachInterrupt(0, zeroCrossing, FALLING); // attatch interrupt pin, ISR and edge
  esc.attach(escPin);
  esc.write(1000); // reset ESC by writing 1000 microseconds
  Serial.begin(115200); // serial baud rate
  Wire.begin(addr); // initialize i2c
  Wire.setClock(400000L); // set i2c clock speed
 
  Wire.beginTransmission(addr);
  Wire.write(0x04); // register to write

  //  Binary   01234567     2_high => enable REF_COUNT_VAL (0x12), 3_low =>  Enable measurement quick termination, 5_high => Use delay from MEASURE_DELAY (0x45)
  Wire.write(0b00100100);
  Wire.endTransmission();

  Wire.beginTransmission(addr);
  Wire.write(0x02); // Acquisition Count
  Wire.write(0x40); // Default is 0x80 // 0d = 13
  Wire.endTransmission();

  Wire.beginTransmission(addr);
  Wire.write(0x12); // Reference acquisition
  Wire.write(0x05); // Count of 3 (default is 5)
  Wire.endTransmission(); 

  delay(500); // delay to prepare ESC
}

void loop() {
  // speed control, analog
  
  int escSpeed = analogRead(0);
  escSpeed = map(escSpeed, 0, 1023, 1000, 1500); // map values from A0 to ESC
  esc.write(escSpeed);
  // take one reading biased, 99 unbiased
  for (int i = 0; i < 100; i++) {
    thisTime = micros();
    if (i == 0) {
      readDistance(true);
    }
    else {
      readDistance(false);
    }
    mCount = i;
    timeDiffer = micros()-thisTime;
    mFreq = 1/(timeDiffer/1000000.0);
  }


}
