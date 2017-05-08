/* //<>//
**
 ** Plotter for warning and monitor system with LiDAR, designed by Simon Ask and Rickard Lindh
 **
 */

import processing.serial.*; 
import controlP5.*; // ControlP5 required install via tools --> add tools --> libraries --> search

ControlP5 cp5;



boolean whatColorMan;


// FOR SERIAL READ
Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// FOR OFFSET IN PLOTTER
float angleOffset = 0;
float distanceOffset = 700;

// DECLARE FOR TEMPORARY STORAGE OF READINGS
FloatList distance, position, timestamp;
int counter=0;
ArrayList<String> serialReadings;

ArrayList<Point> pointArray = new ArrayList<Point>();

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
 //  fullScreen();    //enable fullscreen

  cp5 = new ControlP5(this);
  
  ButtonBar b = cp5.addButtonBar("bar")
    .setPosition(0, 0)
    .setSize(width, 20)
    .addItems(split("a b", " "));
  b.changeItem("a", "text", "Random");
  b.changeItem("b", "text", "White");
  
    cp5.addSlider("AngleOffsetSlider")
     .setRange(0, 360)
     .setCaptionLabel("Angle Offset")
     .setValue(0)
     .setPosition(0, height-40)
     .setSize(100, 10);
     
      cp5.addSlider("DistanceOffsetSlider")
     .setRange(1, 2000)
     .setCaptionLabel("Distance Offset")
     .setValue(700)
     .setPosition(0, height-60)
     .setSize(100, 10);


  frameRate(100);
  background(#000000);

  //SERIAL INIT
  comPort = new Serial(this, Serial.list()[0], 115200);
  comPort.bufferUntil(lf);
  serialReadings = new ArrayList<String>();
}
//SETUP ENDED



void draw() {

  // SET MITPOINT IN THE MIDDLE
  translate(width/2, height/2);

  ellipseMode(CENTER);
  stroke(#D83497);
  fill(#D83497);

  // CLEAR THE LAST ~20 VALUES 
  if (pointArray.size() > 360) {
    for (int i=1; i < serialReadings.size()-2; i++) {
      pointArray.remove(0);
    }
  }

  if (serialReadings.size()>20) {
    for (int i=0; i<serialReadings.size()-2; i++) {

      String data[] = split(serialReadings.get(i), '@');
      if (data.length==3) {

        //CREATE POINT OBJECT WITH CURRENT DATA
        data[0] = Float.toString(map(float(data[0]), 0, 1000, 0, distanceOffset));
   
        Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
        // ADD POINT OBJECT TO ARRAYLIST
        pointArray.add(pointObject);
        
        toPrint = (data[2]);
        
      }
    }
    serialReadings.clear();
  }

  background(#000000);
  
  for (int i = 0; i < pointArray.size(); i++) {
    ellipseMode(RADIUS);

    if (whatColorMan) {
      stroke(#ffffff);
    } else {
      stroke(pointArray.get(i).getColor());
    }

    ellipse(pointArray.get(i).getX(), pointArray.get(i).getY(), 1.5, 1.5);
  }


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

  // PRINT FREQCNT
  fill(0);
  stroke(#ffffff);
  rectMode(CENTER);
  rect(-width/2, (height/2), 70, 30);
  fill(255);
  text(toPrint, -width/2, height/2);
  translate(-width/2, -height/2);
}
// END OF DRAW()


// SERIAL EVENT FUNCTION, CALLED WHEN DATA IS AVAILABLE
void serialEvent(Serial p) { 
  try {

    counter++;
    if (counter>100) {
      inString = p.readStringUntil(',');
      String data[] = split(inString, ',');
      serialReadings.add(data[0]);
    }
  }
  catch(RuntimeException e) {
  }
}

// MENU BAR EVENT
void bar(int n) {
  if (n == 1) {
    whatColorMan = true;
  } else {
    whatColorMan = false;
  }
}

// SLIDER EVENT
public void AngleOffsetSlider(float myOffset) {
  angleOffset = myOffset;
}

// SLIDER EVENT
public void DistanceOffsetSlider(float myOffset) {
  distanceOffset = myOffset;
}