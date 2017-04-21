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

/** Class ZONE **/
class Zone {
  float minDistAngle;
  float lastMinDistAngle;
  float minAngle;
  float maxAngle;
  float minDist = Float.MAX_VALUE;
  float lastMinDist;
  String name;
  boolean collision; 
  int pos = -1;

  //Constructor
  Zone(float minAngleTemp, float maxAngleTemp, String nameTemp) {
    minAngle = minAngleTemp;
    maxAngle = maxAngleTemp;
    name = nameTemp;
  }


  float getLowestDist() {
    if (minDist != Float.MAX_VALUE) {
      lastMinDist = minDist;
    }
    minDist = Float.MAX_VALUE;

    for (int i=0; i<distanceList.size(); i++) {
      if (distanceList.get(i) < minDist && angleList.get(i) > minAngle && angleList.get(i) < maxAngle) {
        pos=i;
        minDist=distanceList.get(i);
      }
    }
    return lastMinDist;
  }

  float getLowestAngle() {

    lastMinDistAngle = minDistAngle;
    if (pos > 0 && pos <101) {
      minDistAngle = angleList.get(pos);
    }

    return minDistAngle;
  }
  boolean collisionOrNot() {

    if (lastMinDist - minDist > 20) {
      collision = true;
    } else {
      collision = false;
    }

    return collision;
  }
  String getName() {
    return name;
  }
}


import processing.serial.*; 

Serial myPort;    // The serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int offset = -20;

//The zones
Zone zoneA; 
Zone zoneB; 
Zone zoneC; 
Zone zoneD; 
Zone zoneE; 
Zone zoneF; 
Zone zoneG; 
Zone zoneH;

boolean wasTrueE = false; 
boolean wasTrueF = false; 


// radius and angle from serial
float angle=0, distance=0;

// lists
FloatList distanceList, angleList;

// timer/counter related
int freqCnt = 0; // frquency counter variable

Timer timer1;
Timer timer2;
Timer timer3;

// string,text related
String toPrint="null";


void setup() { 
  size(700, 700); 
  surface.setResizable(true);
  //fullScreen();
  frameRate(100);
  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.bufferUntil(lf);
  background(#000000);
  timer1 = new Timer();
  timer2 = new Timer(); 
  timer3 = new Timer(); 
  distanceList = new FloatList();
  angleList = new FloatList();

  zoneB = new Zone (0, 0.25*PI, "Zone B");
  zoneA = new Zone (0.25*PI, 0.5*PI, "Zone A"); 
  zoneH = new Zone (0.5*PI, 0.75*PI, "Zone H"); 
  zoneG = new Zone (0.75*PI, PI, "ZoneG"); 
  zoneF = new Zone (PI, 1.25*PI, "Zone F"); 
  zoneE = new Zone (1.25*PI, 1.5*PI, "Zone E"); 
  zoneD = new Zone (1.5*PI, 1.75*PI, "Zone D"); 
  zoneC = new Zone (1.75*PI, 2*PI, "Zone C");
} 

void draw() { 

  if (timer1.getTime() > 1000) {
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
  if (distanceList.size()>100) {
    background(#000000);

    stroke(#0a1528);
    line(-width, 0, width, 0); //Centerline
    line(0, height, 0, -height); 
    line(-width, -height, width, height); 
    line(width, -height, -width, height); 

    fill(255);
    textAlign(CENTER);
    text("Zone A", 50, (-(height/2))+40);
    text("Zone B", (width/2)-40, -80);
    text("Zone C", (width/2)-40, 80);
    text("Zone D", 50, (height/2)-40);

    text("Zone H", -50, (-(height/2))+40);
    text("Zone G", -((width/2)-40), -80);
    text("Zone F", -((width/2)-40), 80);
    text("Zone E", -50, (height/2)-40);


    stroke(#00aaff);
    fill(#00aaff);
    for (int i=0; i < distanceList.size(); i++) {
      float x = (distanceList.get(i) * cos(angleList.get(i)));
      float y = -(distanceList.get(i) * sin(angleList.get(i)));
      ellipseMode(RADIUS);
      ellipse(x, y, 1.5, 1.5);
      //arc(0, 0, x, x, y, y+0.05);
      // point(x,y);
    }
    stroke(#1c1c1c);
    ellipseMode(CENTER);
    ellipse(0, 0, 10, 10);
    noFill();
    ellipse(0, 0, 200, 200);
    ellipse(0, 0, 400, 400);
    ellipse(0, 0, 800, 800);

    stroke(#D83497);




    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ANROPA KLASSEN HÄR



    text("D: "+ zoneB.getLowestDist(), 200, -120);  

    if (zoneB.collisionOrNot()) {
      text(zoneB.getName() + " Collision!", 150, -100);
    }
    text("A: "+ zoneB.getLowestAngle() *( 180 / PI), 250, -150);



    text("D: "+ zoneF.getLowestDist(), -250, 120);  
    //testing to keep the warning 1 sec
    if (zoneF.collisionOrNot()) { 
      text(zoneF.getName() + " Collision!", -150, 100);
      wasTrueF = true;
      timer2.reset();
    } else if (wasTrueF) {
      if (timer2.getTime() < 1000) {
        text(zoneF.getName() + " Collision!", -150, 100);
        wasTrueF = true;
      } else {
        wasTrueF = false;
      }
    }
    text("A: " + zoneF.getLowestAngle() *( 180 / PI), -200, 150);


    zoneE.getLowestDist(); 
    if (zoneE.collisionOrNot()) { 
      text(zoneE.getName() + " Collision!", -100, 300);
      wasTrueE = true;
      timer3.reset();
    } else if (wasTrueE) {
      if (timer3.getTime() < 1000) {
        text(zoneE.getName() + " Collision!", -100, 300);
        wasTrueE = true;
      } else {
        wasTrueE = false;
      }
    }
    zoneE.getLowestAngle(); 



    /*
    if (minAngle >= 0 && minAngle < 0.25*PI && (abs(min - lastMin) > 30)) {
     text("Zone B collision", 110, 220);
     } else if (minAngle >= 0.25*PI && minAngle < 0.5*PI && (abs(min - lastMin) > 30)) {
     text("Zone A collision", 110, 220);
     } else if (minAngle >= 0.5*PI && minAngle < 0.75*PI && (abs(min - lastMin) > 30)) {
     text("Zone H collision", 110, 220);
     } else if (minAngle >= 0.75*PI && minAngle < PI && (abs(min - lastMin) > 30)) {
     text("Zone G collision", 110, 220);
     } else if (minAngle >= PI && minAngle < 1.25*PI && (abs(min - lastMin) > 30)) {
     text("Zone F collision", 110, 220);
     } else if (minAngle >= 1.25*PI && minAngle < 1.5*PI && (abs(min - lastMin) > 30)) {
     text("Zone E collision", 110, 220);
     } else if (minAngle >= 1.5*PI && minAngle < 1.75*PI && (abs(min - lastMin) > 30)) {
     text("Zone D collision", 110, 220);
     } else if (minAngle >= 1.75*PI && minAngle < 2*PI && (abs(min - lastMin) > 30)) {
     text("Zone D collision", 110, 220);
     }
     
     */


    distanceList.clear();
    angleList.clear();
  }

  fill(0); 
  rectMode(CENTER);
  rect(-350, 350, 50, 50);
  fill(255);                 // STEP 4 Specify font color 
  text(toPrint, -340, 350);   // STEP 5 Display Text
} 

void serialEvent(Serial p) { 

  inString = p.readString();

  if (inString.indexOf('&') != -1) { 
    String[] data= split(inString, '&');
    //distance = float(data[0]);
    //distance = map(distance, 0,800, 0, 400);
    angle = radians(float(data[1]));  
    distance = float(data[0]) + offset;
    distance = map(distance, 0, 1000, 0, 800);


    if (distance > 0) {
      distanceList.append(distance);
      angleList.append(angle);
    }

    p.clear();
    freqCnt++;
  }
}