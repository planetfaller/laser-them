/*
**
 ** Plotter for warning and monitor system with LiDAR, designed by Simon Ask and Rickard Lindh
 **
 */

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
  int pos = -1;
  boolean wasTrue = false;
  Timer timer; 

  //Constructor
  Zone(float minAngleTemp, float maxAngleTemp, String nameTemp) {
    minAngle = minAngleTemp;
    maxAngle = maxAngleTemp;
    name = nameTemp;
    timer = new Timer();
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
  boolean proximityWarning() {
    if (lastMinDist < 30)
      return true;
    else {
      return false;
    }
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
      return true;
    } 
    return false;
  }
  


  boolean collisionWithDelay() {
    if (collisionOrNot()) {
      wasTrue = true;
      timer.reset();
      return true;
    } else if (wasTrue) {
      if (timer.getTime() < 1000) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }
  String getName() {
    return name;
  }
} // end of Zone Class


import processing.serial.*; 

Serial myPort;    // The serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int offset = -20;


ArrayList<PVector> inPvectorList = new ArrayList<PVector>(); // stor indata here
ArrayList<PVector> inlinerList = new ArrayList<PVector>(); // used for color 
ArrayList<PVector> pvectorListRansac = new ArrayList<PVector>();
PVector point1,point2,point3, point1Draw, point2Draw;

int[] dataValues; 
String[] dataLines;

float threshold=20;
int hypoLines=200;
int lastInlineCount= 0;
int hypoLinesCount = 0;
int dataPoints2Ransac = 30;
int acqusitions=200;


//The zones
Zone zoneA; 
Zone zoneB; 
Zone zoneC; 
Zone zoneD; 
Zone zoneE; 
Zone zoneF; 
Zone zoneG; 
Zone zoneH;


// radius and angle from serial
float angle=0, distance=0;

// lists
FloatList distanceList, angleList;

// timer/counter related
int freqCnt = 0; // frquency counter variable
Timer timer1;

// string,text related
String toPrint="null";


void setup() { 
  size(700, 700); 
  surface.setResizable(true);
  //fullScreen();    //enable fullscreen
  frameRate(100);
  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.bufferUntil(lf);
  background(#000000);
  timer1 = new Timer();
  distanceList = new FloatList();
  angleList = new FloatList();

  //Create Zone objects
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
  
  // derive frequency

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
  
  // start curent pie draw

  if (distanceList.size()>acqusitions) {
    
    background(#000000);
    // blacken aquisitioned things
      //ellipseMode(RADIUS);
      //fill(#000000);
      //stroke(#000000);
      //arc(0, 0, 350,350,angleList.get(0), angleList.size()-1);
      
    stroke(#0a1528);
    //Zone-lines
    line(-width, 0, width, 0); //Centerline
    line(0, height, 0, -height); 
    line(-width, -height, width, height); 
    line(width, -height, -width, height); 
    //Zone text
    fill(255);
    textAlign(CENTER);

    //Zone text, might wanna change to dynamic numbers --
    text("Zone A", 50, (-(height/2))+40);
    text("Zone B", (width/2)-40, -80);
    text("Zone C", (width/2)-40, 80);
    text("Zone D", 50, (height/2)-40);
    text("Zone H", -50, (-(height/2))+40);
    text("Zone G", -((width/2)-40), -80);
    text("Zone F", -((width/2)-40), 80);
    text("Zone E", -50, (height/2)-40);

    // -- Line mode --
    /*
    float lastX = 0;
    float lastY = 0; 

    for (int i=0; i < distanceList.size(); i++) {
      float lineX = (distanceList.get(i) * cos(angleList.get(i)));
      float lineY = -(distanceList.get(i) * sin(angleList.get(i)));
      line(lineX, lineY, lastX, lastY);
      lastX = lineX;
      lastY = lineY;
    }
    */


    stroke(#1c1c1c);
    ellipseMode(CENTER);
    ellipse(0, 0, 10, 10);
    noFill();
    ellipse(0, 0, 200, 200);
    ellipse(0, 0, 400, 400);
    ellipse(0, 0, 800, 800);
    stroke(#D83497);

    //LowestDist, Collision, angle for Zone B
    text("D: "+ zoneB.getLowestDist(), 200, -120);  
    if (zoneB.collisionOrNot()) {
      text(zoneB.getName() + " Collision!", 150, -100);
    }
    text("A: "+ zoneB.getLowestAngle() *( 180 / PI), 250, -150);


    //LowestDist, Collision, angle for Zone F
    text("D: "+ zoneF.getLowestDist(), -250, 120); 
    if (zoneF.collisionWithDelay()) { 
      text(zoneF.getName() + " Collision!", -150, 100);
    }
    text("A: " + zoneF.getLowestAngle() *( 180 / PI), -200, 150);
    
    //Proximity warning Zone F
    if (zoneF.proximityWarning()) {
      textSize(70);
      text("Zone F proximity warning", 0, 0);
      textSize(12);
    }

    //Collision for Zone E
    zoneE.getLowestDist(); 
    if (zoneE.collisionWithDelay()) {
      text(zoneE.getName() + " Collision!", -100, 300);
    }
    zoneE.getLowestAngle(); 




    stroke(#53F53B);
    for (int i=0; i < distanceList.size(); i++) {
      


      float x = (distanceList.get(i) * cos(angleList.get(i)));
      float y = -(distanceList.get(i) * sin(angleList.get(i)));
      ellipseMode(RADIUS);
      ellipse(x, y, 1.5, 1.5);
      //arc(0, 0, x, x, y, y+0.05);
      //point(x,y);
      
      strokeWeight(1);
      //println(distanceList.size());
      inPvectorList.add(new PVector(x,y));
       //println(inPvectorList.size());
     if(i%dataPoints2Ransac == 1){
        
      // //println("first inpv size" + inPvectorList.size());
       pvectorListRansac = getRansac(inPvectorList);
       stroke(#cceeff);
       // line(pvectorListRansac.get(0).x,pvectorListRansac.get(0).y,pvectorListRansac.get(1).x,pvectorListRansac.get(1).y);
        stroke(#53F53B);
      }  
    }



    distanceList.clear();
    angleList.clear();
  }

  fill(0); 
  rectMode(CENTER);
  rect(-350, 350, 50, 50);
  fill(255);                 
  text(toPrint, -340, 350);  //Prints freq update
} 



ArrayList<PVector> getRansac(ArrayList<PVector> pvIN){


    // we declare a arraylist to store our ransac line 
    ArrayList<PVector> ransacLine = new ArrayList<PVector>();
    ransacLine.add(new PVector(0,0));
    ransacLine.add(new PVector(0,0));
    
    int inlineCounter=0, bestInlineCount=0;

    // We test set number of lines
  for(int i=0;i<hypoLines;i++){
    // we clone our inlist to make some stoof with it
    ////println(pvIN);
    //println("pvIn.size" + pvIN.size());
    ArrayList<PVector> pvInClone = new ArrayList<PVector>();
    pvInClone = (ArrayList<PVector>)pvIN.clone(); // clone indata
    //println("pvInClone.size" + pvInClone.size());
    // first we create hypo line and remove the points we take from it.
    int randP1 = int(random(0,pvIN.size()-1)); // take a random point from data
    point1 = new PVector(pvIN.get(randP1).x, pvIN.get(randP1).y);
    pvInClone.remove(randP1); // remove it
    //pvectorListPie("point1" + point1);
    
    //println("pvinclone size " + pvInClone);
    
    int randP2= int(random(0,pvIN.size()-1)); // and another random point
    point2 = new PVector(pvIN.get(randP2).x, pvIN.get(randP2).y);
    // //println("second rand: " + pvIN.get(randP2)); // debug
    pvInClone.remove(randP2); // remove it

    // //println("point2" + point2);
    
    if (abs(point2.x - point1.x) < 100){
    
    // then we check the distance for each point to this line
    for(int j=0;j<pvIN.size()-2;j++){
      
      float m = (point2.y - point1.y) / (point2.x - point1.x);
      float b = point1.y - m * point1.x;      
      double distance = abs(pvInClone.get(j).y - m * pvInClone.get(j).x - b) / sqrt(1 + m * m); 
      float d = (float)distance;

      if(d < threshold){ // count inliners
        inlineCounter++;
      }  
    }
      
    }
  

    // if the count was good (higher than last line) we store the the ransac line points and the inline count value as best value

    if (inlineCounter > bestInlineCount){
      ransacLine.set(0, point1);
      ransacLine.set(1, point2);
      bestInlineCount = inlineCounter;
    }

    inlineCounter = 0 ; // reset inline counter
  

    }

    // when all is done we return the ransac line
    inPvectorList.clear();
    return ransacLine;

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
    println(angle);
    p.clear();
    freqCnt++;
  }
}