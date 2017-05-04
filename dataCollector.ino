// TIMER CLASS

class Timer
{
    unsigned long startTime;
    boolean timerOn;

    // constructor
  public:
    Timer() {
      startTime = micros();
      timerOn = true;
    }
    // void method to get time, returns unsigned long
    unsigned long getTime() {
      return (micros() - startTime);
    }
    // void method to get time, returns unsigned long
    void reset() {
      startTime = micros();
    }

};

// MAIN STARTS HERE

#include <Wire.h> // Wire libary, to handle I2C
#include <Servo.h> 
#define addr 0x62 // I2C address to LIDAR
#define escPin 5 // ESC pin
#define interruptPin 3 // interrupt for HALL sensor

// MATH
const float pi = 3.14; // PI

//LIDAR I2C VAR

byte byteOne, byteTwo;
byte confirmByte = 255;
word distance,angPos;

// VELOCITY AND POSITION

unsigned long zCTime,lZCTime;
float angVel=0;
boolean zCToggle;
volatile boolean interruptToggled = false;

// ESC // debug not used

Servo esc; // instanciate server object
int setVal=3.0; // setpoint rotation [Hz]
int errorSum=0; // lastError
int kp=5; // gain
int escSpeed=1350;

// Time related 
unsigned long timestamp=0;
unsigned long lastTimeStamp=0;
unsigned int timeDiff=0;

void setup() {
  // INIT SERIAL
  Serial.begin(115200); // serial baud rate

  // INIT I2C

  Wire.begin(addr); // initialize i2c
  Wire.setClock(400000L); // set i2c clock speed
  Wire.beginTransmission(addr);
  Wire.write(0x04); // register to write

  //  Binary 0b01234567     2_high => enable REF_COUNT_VAL (0x12), 3_low =>  Enable measurement quick termination, 5_high => Use delay from MEASURE_DELAY (0x45)
  Wire.write(0b00100000);
  Wire.endTransmission();

  Wire.beginTransmission(addr);
  Wire.write(0x02); // Acquisition Count
  Wire.write(0x0d); // Default is 0x80 // 0d = 13
  Wire.endTransmission();

  Wire.beginTransmission(addr);
  Wire.write(0x12); // Reference acquisition
  Wire.write(0x03); // Count of 3 (default is 5)
  Wire.endTransmission();

  //  Wire.beginTransmission(addr); // make it faster
  //  Wire.write(0x1c); // Reference acquisition
  //  Wire.write(0x60); // Count of 3 (default is 5)
  //  Wire.endTransmission();

  // INIT ISR

  attachInterrupt(1, zCISR, FALLING); // attatch interrupt pin, ISR and edge

  // INIT ESC AND PI

  esc.attach(escPin);
  esc.write(1000); // reset ESC by writing 1000 microseconds

// DELAY STUFF TO GIVE IT TIME TO START

  delay(1000);
  for(int i=1000; i < escSpeed; i++){
    esc.write(i);
    delay(10);
  }
  esc.write(escSpeed);
}

void loop() {
  
  
  // take one reading biased, 99 unbiased
  for (int i = 0; i < 100; i++) {
    if (i == 0) {
      readDistance(true);
    }
    else {
      readDistance(false);
    }

}
}




