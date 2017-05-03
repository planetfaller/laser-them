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
#define addr 0x62 // I2C address to LIDAR

const float pi = 3.14; // PI
byte somethingRead[100];
byte byteOne, byteTwo;
int byteCon[100];
byte confirmByte = 255;
int counter = 0;
word storedDist;
int timestoPrint[100];

// create a timer
Timer timerOne;

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

  //  Wire.beginTransmission(addr);
  //  Wire.write(0x1c); // Reference acquisition
  //  Wire.write(0x60); // Count of 3 (default is 5)
  //  Wire.endTransmission();

  delay(500);

}

void loop() {
  // take one reading biased, 99 unbiased
  for (int i = 0; i < 100; i++) {
    timerOne.reset();
    if (i == 0) {
      readDistance(true);
    }
    else {
      readDistance(false);
    }
//              Serial.print(String(timerOne.getTime(), DEC) + ","); // debug timer
//              timestoPrint[counter] = timerOne.getTime();
//                  if (counter>100){
//                    for(int i=0;i<100;i++){
//                    Serial.println(timestoPrint[i]);
//              
//              
//                    }
//                    delay(500);
//                    counter=0;
//                    }
    counter++;

  }
}




