/**
  360 Degree Rotating LiDAR Lite 3 Measurement System
  Name: arduino-real
  Purpose: Controller code for initializing Lidar Lite 3, and then making continuous
  measurements, in a BLDC driven rotating system, deriving angular position based 
  on hall measurement and transferring measurements through the serial interface

  I2C commands partially sourced from: https://github.com/garmin/LIDARLite_v3_Arduino_Library
  Register functions found in LiDAR Lite 3 datasheet: https://static.garmin.com/pumac/LIDAR_Lite_v3_Operation_Manual_and_Technical_Specifications.pdf

  @author Rickard Lind & Simon Ask
  @version 1.0 20/05/17
*/


/**
    Timer class
*/

class Timer
{
    unsigned long startTime; // instance variable
    
    // constructor, no paramaters
  public:
    Timer() {
      startTime = micros();
    }
    /**
    Get time from timer
  
    @return {unsigned long} current timer time
    */
    unsigned long getTime() {
      return (micros() - startTime);
    }
    /**
    Reset timer
  
    @return void
    */
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
word distance, angPos;

// VELOCITY AND POSITION
unsigned long zCTime, lZCTime; 
float angVel = 0;
boolean zCToggle;
volatile boolean interruptToggled = false;

// ESC 
Servo esc; // instanciate server object
// proportional speed regulator not used but variables declared and initialized for function
int setVal = 3.0; // setpoint rotation [Hz]
int errorSum = 0; // lastError
int kp = 5; // gain

int escSpeed = 1500; // set micro seconds to write to ESC, 1500 ~5 Hz rotation

// TIME RELATED
unsigned long timestamp = 0;
unsigned long lastTimeStamp = 0;
unsigned int timeDiff = 0;

void setup() {
  
  // INIT SERIAL
  Serial.begin(115200); // serial baud rate

  // INIT I2C
  Wire.begin(addr); // initialize i2c
  Wire.setClock(400000L); // set i2c clock speed
  Wire.beginTransmission(addr);
  Wire.write(0x04); // register to write

  // BINARY 0b01234567     2_high => enable REF_COUNT_VAL (0x12), 3_low =>  Enable measurement quick termination, 5_high => Use delay from MEASURE_DELAY (0x45)
  Wire.write(0b00100000);
  Wire.endTransmission();

  // SET ACQUISITION COUNT
  Wire.beginTransmission(addr);
  Wire.write(0x02); // acquisition Count
  Wire.write(0x0d); // default is 0x80 // 0d = 13
  Wire.endTransmission();

  // SET REFERENCE ACQUISTION
  Wire.beginTransmission(addr);
  Wire.write(0x12); // reference acquisition
  Wire.write(0x03); // count of 3 (default is 5)
  Wire.endTransmission();

  // INIT ISR
  attachInterrupt(1, zCISR, FALLING); // attatch interrupt pin, ISR and edge

  // INIT ESC AND PI
  esc.attach(escPin);
  esc.write(1000); // reset ESC by writing 1000 microseconds

  // DELAY ESC INIT TO GIVE IT TIME TO START
  delay(2000);

  //INCREMENTAL MOTOR SPEED 
  for (int i = 1000; i < escSpeed; i++) { // we speed up incrementally
    esc.write(i);
    delay(10);
  }
  esc.write(escSpeed); 
}


// MAIN LOOP
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

