/* //<>//
**
 ** Plotter for warning and monitor system with LiDAR, designed by Simon Ask and Rickard Lindh
 **
 */

import processing.serial.*; 

// FOR SERIAL READ
Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// FOR OFFSET IN PLOTTER
int offset = 20;

// DECLARE FOR TEMPORARY STORAGE OF READINGS
FloatList distance, position, timestamp;
int counter=0;
ArrayList<String> serialReadings;

// RANSAC VARIABLES
ArrayList<PVector> inPvectorList = new ArrayList<PVector>(); 
ArrayList<PVector> pvectorListRansac = new ArrayList<PVector>();
PVector point1, point2;

float threshold=20;
int hypoLines=200;
int lastInlineCount= 0;
int hypoLinesCount = 0;
int dataPoints2Ransac = 30;
int acqusitions=250;


// ZONE OBJECTS
Zone zoneA; 
Zone zoneB; 
Zone zoneC; 
Zone zoneD; 
Zone zoneE; 
Zone zoneF; 
Zone zoneG; 
Zone zoneH;


// STORED VALUES IN LISTS
FloatList distanceList, angleList, timeList;

// TIMER OBJECT
Timer timer1;

//FREQUENCY STRING
String toPrint="null";


void setup() { 

  //WINDOW SETUP
  size(700, 700); 
  surface.setResizable(true);
  //fullScreen();    //enable fullscreen
  frameRate(100);
  background(#000000);

  //SERIAL INIT
  comPort = new Serial(this, Serial.list()[0], 115200);
  comPort.bufferUntil(lf);
  serialReadings = new ArrayList<String>();

  //TIMER CREATED AND VALUELISTS
  timer1 = new Timer();
  distanceList = new FloatList();
  angleList = new FloatList();
  timeList = new FloatList();

  //ZONE OBJECTS CREATED
  zoneB = new Zone (0, 0.25*PI, "Zone B");
  zoneA = new Zone (0.25*PI, 0.5*PI, "Zone A"); 
  zoneH = new Zone (0.5*PI, 0.75*PI, "Zone H"); 
  zoneG = new Zone (0.75*PI, PI, "ZoneG"); 
  zoneF = new Zone (PI, 1.25*PI, "Zone F"); 
  zoneE = new Zone (1.25*PI, 1.5*PI, "Zone E"); 
  zoneD = new Zone (1.5*PI, 1.75*PI, "Zone D"); 
  zoneC = new Zone (1.75*PI, 2*PI, "Zone C");
}
//SETUP ENDED


void draw() { 

  int dataSize = serialReadings.size()-1;
  for (int i=1; i < dataSize; i++) {
    String data[] = split(serialReadings.get(i), '@');
    println(data[0]);
    println(data[1]);
    println(data[2]);
    if (int(data[0]) != 1) {
      distanceList.append(float(data[0]));
      angleList.append(radians(float(data[1])));
      

       // UPDATE FREQCNT EVERY SECOND
      // if (timer1.getTime() > 1000) {  
         toPrint = data[2];
         timer1.reset();
      // }

    }



    timer1.reset();
  }

  serialReadings.clear();


  // SET MITPOINT IN THE MIDDLE
  translate(width/2, height/2);
  ellipseMode(CENTER);
  stroke(#D83497);
  fill(#D83497);

  // START CURRENT PIE DRAW
  if (distanceList.size()>acqusitions) {

    background(#000000);
    // blacken aquisitioned things
    // ellipseMode(RADIUS);
    // fill(#000000);
    // stroke(#000000);
    // arc(0, 0, 350,350,angleList.get(0), angleList.size()-1);


    // VISUALIZE THE ZONES
    stroke(#0a1528);
    line(-width, 0, width, 0); //Centerline
    line(0, height, 0, -height); 
    line(-width, -height, width, height); 
    line(width, -height, -width, height); 

    //ZONE TEXT, SHOULD BE CHANGED TO DYNAMIC NUMBERS
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

    // VISUALIZE DISTANCES WITH ELIPSES
    stroke(#1c1c1c);
    ellipseMode(CENTER);
    ellipse(0, 0, 10, 10); // Small middlepoint
    noFill();
    ellipse(0, 0, 200, 200);
    ellipse(0, 0, 400, 400);
    ellipse(0, 0, 800, 800);


    //LowestDist, Collision, angle for Zone B
    stroke(#D83497);
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
    //if (zoneF.proximityWarning()) {
    //  textSize(70);
    //  text("Zone F proximity warning", 0, 0);
    //  textSize(12);
    //}

    //Collision for Zone E
    zoneE.getLowestDist(); 
    if (zoneE.collisionWithDelay()) {
      text(zoneE.getName() + " Collision!", -100, 300);
    }
    zoneE.getLowestAngle(); 


    // VISUALIZE THE MEASURED DISTANCES
    stroke(#53F53B);
    for (int i=0; i < distanceList.size(); i++) {

      float x = (distanceList.get(i) * cos(angleList.get(i)));
      float y = -(distanceList.get(i) * sin(angleList.get(i)));
      ellipseMode(RADIUS);
      ellipse(x, y, 1.5, 1.5);


      //RANSAC
      strokeWeight(1);
      inPvectorList.add(new PVector(x, y));

      if (i%dataPoints2Ransac == 1) {

        //println("first inpv size" + inPvectorList.size());
        pvectorListRansac = getRansac(inPvectorList);
        stroke(#cceeff);
        // line(pvectorListRansac.get(0).x,pvectorListRansac.get(0).y,pvectorListRansac.get(1).x,pvectorListRansac.get(1).y);
        stroke(#53F53B);
      }
    }


    distanceList.clear();
    angleList.clear();
    timeList.clear();
  }
  
  // PRINT FREQCNT
  fill(0);
  rectMode(CENTER);
  rect(-350, 350, 50, 50);
  fill(255);
  text(toPrint, -340, 350);
  
}
// END OF DRAW()


// RANSAC FUNCTION
ArrayList<PVector> getRansac(ArrayList<PVector> pvIN) {

  // DECLARE A ARRAYLIST TO STORE RANSAC LINE
  ArrayList<PVector> ransacLine = new ArrayList<PVector>();
  ransacLine.add(new PVector(0, 0));
  ransacLine.add(new PVector(0, 0));
  int inlineCounter=0, bestInlineCount=0;

  // TEST SET NUMBER OF LINES
  for (int i=0; i<hypoLines; i++) {

    // Clone our inlist to make some stoof with it
    ArrayList<PVector> pvInClone = new ArrayList<PVector>();
    pvInClone = (ArrayList<PVector>)pvIN.clone();

    // Create hypo line and remove the points we take from it, take a random point from data.
    int randP1 = int(random(0, pvIN.size() - 1)); 
    point1 = new PVector(pvIN.get(randP1).x, pvIN.get(randP1).y);
    pvInClone.remove(randP1); // remove it

    // Another random point
    int randP2= int(random(0, pvIN.size()-1)); 
    point2 = new PVector(pvIN.get(randP2).x, pvIN.get(randP2).y);
    pvInClone.remove(randP2); // remove it

    if (abs(point2.x - point1.x) < 100) {

      // Check the distance for each point to this line
      for (int j=0; j<pvIN.size()-2; j++) {

        float m = (point2.y - point1.y) / (point2.x - point1.x);
        float b = point1.y - m * point1.x;      
        double distance = abs(pvInClone.get(j).y - m * pvInClone.get(j).x - b) / sqrt(1 + m * m); 
        float d = (float)distance;

        // COUNT INLINERS
        if (d < threshold) { 
          inlineCounter++;
        }
      }
    }

    // If the count was good (higher than last line) we store the ransac line points and the inline count value as best value
    if (inlineCounter > bestInlineCount) {
      ransacLine.set(0, point1);
      ransacLine.set(1, point2);
      bestInlineCount = inlineCounter;
    }
    inlineCounter = 0 ; // reset inline counter
  }
  // When all is done we return the ransac line
  inPvectorList.clear();
  return ransacLine;
}

// SERIAL EVENT FUNCTION, CALLED WHEN DATA IS AVAILABLE
void serialEvent(Serial p) { 
  try {

    counter++;
    if (counter>0) {
      inString = p.readStringUntil(',');
      String data[] = split(inString, ',');
      serialReadings.add(data[0]);

    }
  }
  catch(RuntimeException e) {
  }
}