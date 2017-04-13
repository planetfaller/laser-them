// simple timer. remember to start with reset(). 

class Timer
{
  long startTime;

// constructor, starts timer 

Timer(){
  startTime = millis();
}

// get time passed from start

long getTime(){
  return (millis()-startTime);
}

// restart timer

void reset(){
  startTime = millis();
}

}



import processing.serial.*; 
 
Serial myPort;    // The serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int offset = -20;
// radius and angle from serial

float angle=0,distance=0;

// lists

FloatList distanceList, angleList;

// timer/counter related

int freqCnt = 0; // frquency counter variable

Timer timer1;

// string,text related

String toPrint="null";

 
void setup() { 
  size(1000,1000); 
  frameRate(60);
  myPort = new Serial(this, Serial.list()[2], 115200); 
  myPort.bufferUntil(lf);
  background(#505050);
  timer1 = new Timer();
  distanceList = new FloatList();
  angleList = new FloatList();
} 
 
void draw() { 
  
 if (timer1.getTime() > 1000){
     toPrint = str(freqCnt);
     freqCnt = 0;
     timer1.reset();
  }
  
  
  
  
  translate(width/2, height/2);
  stroke(#575A59);
  fill(#D83497);
  ellipseMode(CENTER);
  
  stroke(#D83497);
  fill(#D83497);
if (distanceList.size()>100){
  background(#505050);
  for (int i=0; i < distanceList.size();i++){
  //  float distance = distanceList.get(i);
    float x = (distanceList.get(i) * cos(angleList.get(i)));
    float y = -distanceList.get(i) * sin(angleList.get(i));
    ellipseMode(RADIUS);
    ellipse(x, y, 3, 3);
    //arc(0, 0, x, x, y, y+0.05);
     // point(x,y);
  }
    stroke(#575A59);
  fill(#D83497);
  ellipseMode(CENTER);
  ellipse(0,0, 10,10);
  noFill();
  ellipse(0,0, 200,200);
  ellipse(0,0, 400,400);
  ellipse(0,0, 800,800);
  
  distanceList.clear();
  angleList.clear();
}
  
  fill(0); 
  rectMode(CENTER);
  rect(-350,350,400,50);
  fill(255);                         // STEP 4 Specify font color 
  text(toPrint,-350,350);   // STEP 5 Display Text
} 
 
void serialEvent(Serial p) { 

  inString = p.readString();

  if (inString.indexOf('&') != -1){ 
    String[] data= split(inString, '&');
    //distance = float(data[0]);
    //distance = map(distance, 0,800, 0, 400);
    angle = radians(float(data[1]));  
    distance = float(data[0]) + offset;
    distance = map(distance, 0,500, 0, 500);
    
    distanceList.append(distance);
    angleList.append(angle);  
    
    p.clear();
    freqCnt++;
  }
  

} 