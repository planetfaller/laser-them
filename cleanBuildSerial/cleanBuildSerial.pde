/*
**
 ** Plotter for warning and monitor system with LiDAR, designed by Simon Ask and Rickard Lindh
 **
 */


import controlP5.*; // ControlP5 required install via tools --> add tools --> libraries --> search
import java.util.Collections; // For sorting
import processing.serial.*; 


// COUNTS

float timeCounter=0;
int pointCounter=0;
int errorCounter = 0;
float lastAngle = 0;
float rotFreq=0;
float lastTime=1000;


// GUI
ControlP5 cp5; 
boolean linemodeOn;
boolean ransacOn;
boolean pointmodeOn;
boolean onlyPointmodeOn;

int m, b, ransacHypos, ransacThreshold; // Ransac
int eps, minPts, clusterCount; //   DBSCAN

// DATA AND SERIAL 

ArrayList<Point> pointArray = new ArrayList<Point>(); // Data input array
int filterOut;

// FOR SERIAL
Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// DECLARE FOR TEMPORARY STORAGE OF READINGS
FloatList distance, position, timestamp;
int counter=0;
ArrayList<String> serialReadings;
int maxNumberOfPoints=220;

// COLORS AND GUI
color[] colorList; 
int noc;
color bgColor;


// FOR OFFSET IN PLOTTER
float angleOffset = 0;
float distanceOffset = 700;


int pointArraySize;

// FOR COMPARETO

int xory=0; // Sort ascending X/Y. 0/1



void setup() {
  //WINDOW SETUP
  size(700, 700); 
  surface.setResizable(true);
  //  fullScreen();    //enable fullscreen

  // FOR GUI
  cp5 = new ControlP5(this);

  ButtonBar onlyPointBar = cp5.addButtonBar("onlyPointBar")
    .setPosition(0, 20)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  onlyPointBar.changeItem("a", "text", "On");
  onlyPointBar.changeItem("b", "text", "Off");

  ButtonBar pointBar = cp5.addButtonBar("pointBar")
    .setPosition(0, 60)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  pointBar.changeItem("a", "text", "On");
  pointBar.changeItem("b", "text", "Off");

  ButtonBar lineBar = cp5.addButtonBar("lineBar")
    .setPosition(0, 100)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  lineBar.changeItem("a", "text", "On");
  lineBar.changeItem("b", "text", "Off");

  ButtonBar ransacBar = cp5.addButtonBar("ransacBar")
    .setPosition(0, 140)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  ransacBar.changeItem("a", "text", "On");
  ransacBar.changeItem("b", "text", "Off");

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

  cp5.addTextfield("Max Number Of Points")
    .setPosition(0, 200)
    .setText("100")
    .setSize(100, 20)
    .setAutoClear(false);

  cp5.addTextfield("epsValue")
    .setPosition(0, 250)
    .setText("20")
    .setSize(100, 20)
    .setAutoClear(false);

  cp5.addTextfield("minPtsValue")
    .setPosition(0, 300)
    .setText("3")
    .setSize(100, 20)
    .setAutoClear(false);


  // FOR RANSAC

  ransacHypos = 200; // Ransac lines to try
  ransacThreshold = 10; // Inliner threshold

  // FOR DBSCAN
  clusterCount=0; // how many clusters in data set



  // FOR COLORS
  noc = 1000; // number of colors
  colorList = new color[noc]; // color array

  for (int i=0; i<1000; i++) // Populate color array with random colors
  {
    colorList[i] = color(random(0, 255), random(0, 255), random(0, 255));
  }

  bgColor=40;


  // FOR DATA

  filterOut=10; // filter out measurements closer than filterOut

  //SERIAL INIT

  comPort = new Serial(this, Serial.list()[0], 115200);
  comPort.bufferUntil(lf);
  serialReadings = new ArrayList<String>();
}

void draw() {
  background(bgColor); // background color
  translate(width/2, height/2); // translate origin to middle

  stroke(#ffffff);
  noFill();

  
  ellipse(0,0,map(200,0,1000,0,distanceOffset),map(200,0,1000,0,distanceOffset));
  fill(#ffffff);
  rect(-25, -30, 50, 60);
  text("Point Mode", -width/2, -height/2+15);
  text("Cluster Mode", -width/2, -height/2+55);
  text("Line Mode", -width/2, -height/2+95);
  text("Ransac Mode", -width/2, -height/2+135);

  int xCoordinator = mouseX - width/2;
  int yCoordinator = mouseY - width/2;
 // float totalDistanceToMouse = sqrt(pow(float(yCoordinator),2) + pow(float(xCoordinator),2)); 
  float totalDistanceToMouse = map(sqrt(pow(float(yCoordinator),2) + pow(float(xCoordinator),2)),0,1000,0,distanceOffset);
  
  text(totalDistanceToMouse, -width/2, -height/2 + 550);
  text(pointCounter, -width/2 + 50, -height/2 + 450);
  text(rotFreq, -width/2, -height/2 + 400);
  text(1/(lastTime/1000000), -width/2, -height/2 + 350);
  text(errorCounter, -width/2, -height/2 + 600);
  // text(1/(timeCounter/1000000), -width/2, -height/2 + 350);
  
  int paSize = pointArray.size(); // store the size for use 

  dealWithSerial(); // DO IT
 
  
  

  if (pointArray.size() > 100) { 

    if (onlyPointmodeOn) {
      drawOnlyPoints();
    }

    DBSCAN(pointArray); // DBSCAN points for clustering DBSCAN gives each point in set a clusterID

    // draw point chart 
    if (pointmodeOn) {
      drawPoints();
    }
    // draw line connected point chart
    if (linemodeOn) {
      drawConnectedPoints();
    }

    // draw some text



    // Build individual point clouds based on cluster ID

    for (int j=1; j< clusterCount-1; j++) { // minus one

      ArrayList<Point> dbArray = new ArrayList<Point>(); // collect clusters
      for (int i=0; i < pointArray.size(); i++) { // minus one
        if (pointArray.get(i).getClusterID()==j) {
          dbArray.add(pointArray.get(i));
        }
      }

      if (dbArray.size() > 10) {

        Collections.sort(dbArray); // sort array on X ascending

        // drawClusterConnectedPoints(dbArray); // draw line connected point chart based on cluster

        if (ransacOn) {
          drawRansacCluster(dbArray); // draw RANSAC lines based on clusters
        }
      }
    }
  }  

  translate(-width/2, -height/2);
}// END OF DRAW

void drawPoints() {
  for (int i=0; i < pointArray.size(); i++)
  {
    color clusterColor = (colorList[pointArray.get(i).getClusterID()]);
    stroke(clusterColor);
    if (pointArray.get(i).getClusterID()==0) {
      noFill();
      // ellipse(pointArray.get(i).getX(),pointArray.get(i).getY(), 20,20);
    } else
    {
      //  println(pointArray.get(i).getTime());
      fill(clusterColor);
      rect(pointArray.get(i).getX(), pointArray.get(i).getY(), 2, 2);
    }
  }
}


void drawOnlyPoints() {
  for (int i = 0; i < pointArray.size(); i++) {
    stroke(#ffffff);
    ellipse(pointArray.get(i).getX(), pointArray.get(i).getY(), 2, 2);
  }
}


void drawConnectedPoints() {
  for (int i=0; i < pointArray.size()-1; i++) { // draw point connected chart
    stroke(colorList[800]);
    line(pointArray.get(i).getX(), pointArray.get(i).getY(), pointArray.get(i+1).getX(), pointArray.get(i+1).getY());
  }
}

// draw cluster points connected charts

void drawClusterConnectedPoints(ArrayList<Point> dbArray) {
  for (int i=0; i < dbArray.size()-1; i++) { 
    stroke(colorList[i]);
    line(dbArray.get(i).getX(), dbArray.get(i).getY(), dbArray.get(i+1).getX(), dbArray.get(i+1).getY());
  }
}


void drawRansacCluster(ArrayList<Point> dbArray) {
  float xmin=dbArray.get(0).getX();
  float xmax=dbArray.get(dbArray.size()-1).getX();

  xory = 1;
  Collections.sort(dbArray);

  float ymin = dbArray.get(0).getY();
  float ymax = dbArray.get(dbArray.size()-1).getY();

  xory = 0;


  float[] bmCoeff =  new float[2];
  bmCoeff = getRansac(dbArray, ransacHypos, ransacThreshold);

  float yb1 = bmCoeff[0]*xmin+bmCoeff[1]; // bx + m
  float yb2 = bmCoeff[0]*xmax+bmCoeff[1]; 
  float xb1;

  if (yb1 < ymin)
  { // yb1 less than y min, calculate x based on y min
    xb1 = (ymin-bmCoeff[1])/bmCoeff[0];
    yb1 = ymin;
  } else if (yb1 > ymax)
  { // yb1 bigger than y max, calculate x based on y max
    xb1 = (ymax-bmCoeff[1])/bmCoeff[0];
    yb1 = ymax;
  } else
  {
    xb1 = xmin; // else all is good we go with values we got
  }

  float xb2;
  if (yb2 < ymin)
  { // yb1 less than y min, calculate x based on y min
    xb2 = (ymin-bmCoeff[1])/bmCoeff[0];
    yb2 = ymin;
  } else if (yb2 > ymax)
  { // yb1 bigger than y max, calculate x based on y max
    xb2 = (ymax-bmCoeff[1])/bmCoeff[0];
    yb2 = ymax;
  } else
  {
    xb2 = xmax; // else all is good we go with values we got
  }

  stroke(colorList[800]);
  line(xb1, yb1, xb2, yb2);
}




// SERIAL EVENT FUNCTION, CALLED WHEN DATA IS AVAILABLE

void dealWithSerial() {
  if (pointArray.size() > maxNumberOfPoints) {
    for (int i=1; i < serialReadings.size()-2; i++) {
      pointArray.remove(0);
    }
  }

  if (serialReadings.size()>20) {
    for (int i=0; i<serialReadings.size()-1; i++) {

      String data[] = split(serialReadings.get(i), '@');
      if (data.length==3 && data != null) {

        //CREATE POINT OBJECT WITH CURRENT DATA
        int distance = int(data[0]);
        data[0] = Float.toString(map(float(data[0]), 0, 1000, 0, distanceOffset));
        float angle = float(data[1]);
        int timeDiff = int(data[2]);
         println(rotFreq);
         if (angle < 10 && lastAngle > 350){
           
           if (timeCounter > 0){
            rotFreq = 1/((timeCounter)/1000000);
           }
           pointCounter = 0;
           timeCounter = 0;
           errorCounter = 0;
         }
         
         pointCounter++;
         timeCounter = timeDiff + timeCounter;
         lastTime = timeDiff;
         lastAngle = angle;
         
         if (distance == 1){
           errorCounter++;
         }


        if (float(data[0]) > filterOut) {
          Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
          // ADD POINT OBJECT TO ARRAYLIST
          //println(pointObject.getX());
          pointArray.add(pointObject);
          // inPointArray.add(pointObject);
          
        }
      }
    }
    serialReadings.clear();
  }
}


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
void ransacBar(int n) {
  if (n == 1) {
    ransacOn = false;
  } else {
    ransacOn = true;
  }
}
void lineBar(int n) {
  if (n == 1) {
    linemodeOn = false;
  } else {
    linemodeOn = true;
  }
}
void pointBar(int n) {
  if (n == 1) {
    pointmodeOn = false;
  } else {
    pointmodeOn = true;
  }
}
void onlyPointBar(int n) {
  if (n == 1) {
    onlyPointmodeOn = false;
  } else {
    onlyPointmodeOn = true;
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

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {

    if (theEvent.getName() == "epsValue") {
      eps = int(theEvent.getStringValue());
    } 
    
    else if (theEvent.getName() == "minPtsValue") {
      minPts = int(theEvent.getStringValue());
    } 
    
    else if (theEvent.getName() == "pointArraySizeValue") {
      maxNumberOfPoints = int(theEvent.getStringValue());
      println(pointArraySize);
    }
  }
}