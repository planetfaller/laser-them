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
float angRes=0;

// OCCUPY GRID

int[][] grid = new int[40][40]; // create a hundred by hundred occupy grid



// GUI
ControlP5 cp5; 
boolean linemodeOn;
boolean ransacOn;
boolean clusterPointmodeOn;
boolean onlyPointmodeOn;
boolean rectmodeOn;

// Ransac
int m, b; 
int ransacHypos = 200; // Ransac lines to try
int ransacThreshold = 10; // Inliner threshold

// DBSCAN
int clusterCount; 
int eps = 20;
int minPts = 3;

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
float distanceOffset = 1;

int pointArraySize;

// FOR COMPARETO

int xory=0; // Sort ascending X/Y. 0/1

// FOR DBSCAN

int currentNumberOfClusters = 0;

void setup() {
  //WINDOW SETUP
  //size(1200, 700); 
  // surface.setResizable(true);
  fullScreen();    //enable fullscreen

  // FOR GUI
  cp5 = new ControlP5(this);

  ButtonBar onlyPointBar = cp5.addButtonBar("onlyPointBar")
    .setPosition(0, 20)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  onlyPointBar.changeItem("a", "text", "On");
  onlyPointBar.changeItem("b", "text", "Off");

  ButtonBar clusterPointBar = cp5.addButtonBar("clusterPointBar")
    .setPosition(0, 60)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  clusterPointBar.changeItem("a", "text", "On");
  clusterPointBar.changeItem("b", "text", "Off");

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

  ButtonBar rectBar = cp5.addButtonBar("rectBar")
    .setPosition(0, 180)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  rectBar.changeItem("a", "text", "On");
  rectBar.changeItem("b", "text", "Off");

  cp5.addSlider("AngleOffsetSlider")
    .setRange(0, 360)
    .setCaptionLabel("Angle Offset")
    .setValue(0)
    .setPosition(0, height-20)
    .setSize(100, 10);

  cp5.addSlider("DistanceOffsetSlider")
    .setRange(0.1, 1.5)
    .setCaptionLabel("Distance Scale")
    .setValue(1)
    .setPosition(0, height-40)
    .setSize(100, 10);

  cp5.addTextfield("Max Number Of Points")
    .setPosition(0, 220)
    .setText("220")
    .setInputFilter(1)
    .setSize(100, 20)
    .setAutoClear(false);

  cp5.addTextfield("epsValue")
    .setPosition(0, 270)
    .setText("20")
    .setInputFilter(1)
    .setSize(100, 20)
    .setAutoClear(false);

  cp5.addTextfield("minPtsValue")
    .setPosition(0, 320)
    .setText("3")
    .setInputFilter(1)
    .setSize(100, 20)
    .setAutoClear(false);

  cp5.addTextfield("Ransac Threshold")
    .setPosition(0, 370)
    .setText("10")
    .setInputFilter(1)
    .setSize(100, 20)
    .setAutoClear(false);

  cp5.addTextfield("Ransac Hypos")
    .setPosition(0, 420)
    .setText("200")
    .setInputFilter(1)
    .setSize(100, 20)
    .setAutoClear(false);


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

  // readData();
}

void draw() {
  background(bgColor); // background color
  translate(width/2, height/2); // translate origin to middle

  stroke(100);
  noFill();

  readSerial();

  for (int i=0; i<40; i++) {
    for (int j=0; j < 40; j++) {
      if (grid[i][j]>0) {
         text(grid[i][j], (i*50)-1000,(j*50)-1000);
      }
    }
  }



  ellipse(0, 0, 200 * distanceOffset, 200 * distanceOffset);
  ellipse(0, 0, 600 * distanceOffset, 600 * distanceOffset);
  ellipse(0, 0, 1000 * distanceOffset, 1000 * distanceOffset);
  ellipse(0, 0, 2000 * distanceOffset, 2000 * distanceOffset);

  fill(100);
  rect(-15*distanceOffset, -15*distanceOffset, 30*distanceOffset, 30*distanceOffset);
  fill(#ffffff);

  drawGUIText();



  // dealWithSerial(); // Serial Communication

  if (pointArray.size() > 100) {

    int[] clusters = DBSCAN(pointArray); // DBSCAN points for clustering DBSCAN gives each point in set a clusterID
    currentNumberOfClusters = max(clusters); // store current number of clusters 

    if (onlyPointmodeOn) {
      drawOnlyPoints();
    }


    // draw point chart 
    if (clusterPointmodeOn) {
      drawClusterPoints();
    }
    // draw line connected point chart
    // drawConnectedPoints();



    if (linemodeOn) {
      drawClusterConnectedPoints(); // draw line connected point chart based on cluster
    }

    //if (rectmodeOn) {
    //  drawRect();
    //stroke(#ff0000);
    //noFill();
    //rect(xb1 * distanceOffset, yb1 * distanceOffset, (xb2-xb1) * distanceOffset, (yb2-yb1) * distanceOffset);
    //}


    if (ransacOn || rectmodeOn) {
      drawRectRansac();
    }
  }

  translate(-width/2, -height/2);
}// END OF DRAW


//void drawPoints() {
//  for (int i=0; i < pointArray.size(); i++)
//  {
//    color clusterColor = (colorList[pointArray.get(i).getClusterID()]);
//    stroke(clusterColor);
//    if (pointArray.get(i).getClusterID()==0) {
//      noFill();
//      // ellipse(pointArray.get(i).getX(),pointArray.get(i).getY(), 20,20);
//    } else
//    {
//      fill(clusterColor);
//      text(str(pointArray.get(i).getClusterID()),pointArray.get(i).getX(),pointArray.get(i).getY());
//      rect(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, 2, 2);

//    }
//  }
//}


void drawClusterPoints() {
  for (int i=0; i < pointArray.size(); i++) { // loop through points in set
    if (pointArray.get(i).getClusterID()==0) { // is clusterID is zero its an outlier and is not drawn
      noFill();
      // ellipse(pointArray.get(i).getX(),pointArray.get(i).getY(), 20,20);
    } else
    {
      color clusterColor = (colorList[pointArray.get(i).getClusterID()]); // pick a color for each clusterID
      stroke(clusterColor);
      fill(clusterColor);
      text(str(pointArray.get(i).getClusterID()), pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset);
      rect(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, 4, 4);
    }
  }
}



void drawOnlyPoints() {
  for (int i = 0; i < pointArray.size(); i++) {
    stroke(#ffffff);
    ellipse(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, 2, 2);
  }
}


void drawConnectedPoints() {
  stroke(colorList[800]);
  for (int i=0; i < pointArray.size()-1; i++) { // draw point connected chart
    line(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, pointArray.get(i+1).getX() * distanceOffset, pointArray.get(i+1).getY() * distanceOffset);
  }
}

// draw cluster points connected charts
//void drawClusterConnectedPoints(ArrayList<Point> dbArray) {
//  stroke(colorList[int(random(999))]);
//  for (int i=0; i < dbArray.size()-1; i++) {
//    line(dbArray.get(i).getX() * distanceOffset, dbArray.get(i).getY() * distanceOffset, dbArray.get(i+1).getX() * distanceOffset, dbArray.get(i+1).getY() * distanceOffset);
//   }
//}


void drawClusterConnectedPoints() {
  xory=2;
  Collections.sort(pointArray);

  for (int i=0; i < pointArray.size()-1; i++) {
    int currentCluster = pointArray.get(i).getClusterID();
    if (currentCluster > 0) {
      color clusterColor = (colorList[currentCluster]); // pick a color for each clusterID
      stroke(clusterColor);
      line(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, pointArray.get(i+1).getX() * distanceOffset, pointArray.get(i+1).getY() * distanceOffset);
    }
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

  if (yb1 < ymin) { // yb1 less than y min, calculate x based on y min
    xb1 = (ymin-bmCoeff[1])/bmCoeff[0];
    yb1 = ymin;
  } else if (yb1 > ymax) { // yb1 bigger than y max, calculate x based on y max
    xb1 = (ymax-bmCoeff[1])/bmCoeff[0];
    yb1 = ymax;
  } else {
    xb1 = xmin; // else all is good we go with values we got
  }

  float xb2;
  if (yb2 < ymin) { // yb1 less than y min, calculate x based on y min
    xb2 = (ymin-bmCoeff[1])/bmCoeff[0];
    yb2 = ymin;
  } else if (yb2 > ymax) { // yb1 bigger than y max, calculate x based on y max
    xb2 = (ymax-bmCoeff[1])/bmCoeff[0];
    yb2 = ymax;
  } else {
    xb2 = xmax; // else all is good we go with values we got
  }



  if (ransacOn) {
    stroke(colorList[800]);
    line(xb1 * distanceOffset, yb1 * distanceOffset, xb2 * distanceOffset, yb2 * distanceOffset);
  }

  if (rectmodeOn) {
    stroke(#ff0000);
    noFill();
    rect(xmin * distanceOffset, ymin * distanceOffset, (xmax-xmin) * distanceOffset, (ymax-ymin) * distanceOffset);
  }
}


void drawRectRansac() {
  // Build individual point clouds based on cluster ID
  ArrayList<Point> dbArray = new ArrayList<Point>(); // collect clusters

  for (int i=1; i <= currentNumberOfClusters; i++) { // minus one 

    for (int j=0; j < pointArray.size()-1; j++) { // minus one
      if (pointArray.get(j).getClusterID()==i) {
        dbArray.add(pointArray.get(j));
      }
    }

    xory=0;
    Collections.sort(dbArray); // sort array on X ascending
    float xmax = dbArray.get(dbArray.size()-1).getX();
    float xmin = dbArray.get(0).getX();

    xory=1;
    Collections.sort(dbArray); // sort array on Y ascending   
    float ymax = dbArray.get(dbArray.size()-1).getY();
    float ymin = dbArray.get(0).getY();

    if (rectmodeOn) {
      stroke(#ff0000);
      noFill();
      rect(xmin * distanceOffset, ymin * distanceOffset, (xmax-xmin) * distanceOffset, (ymax-ymin) * distanceOffset);
    }
    // 


    float[] bmCoeff =  new float[2];
    bmCoeff = getRansac(dbArray, ransacHypos, ransacThreshold);

    float yb1 = bmCoeff[0]*xmin+bmCoeff[1]; // bx + m
    float yb2 = bmCoeff[0]*xmax+bmCoeff[1]; 
    float xb1;

    if (yb1 < ymin) { // yb1 less than y min, calculate x based on y min
      xb1 = (ymin-bmCoeff[1])/bmCoeff[0];
      yb1 = ymin;
    } else if (yb1 > ymax) { // yb1 bigger than y max, calculate x based on y max
      xb1 = (ymax-bmCoeff[1])/bmCoeff[0];
      yb1 = ymax;
    } else {
      xb1 = xmin; // else all is good we go with values we got
    }

    float xb2;
    if (yb2 < ymin) { // yb1 less than y min, calculate x based on y min
      xb2 = (ymin-bmCoeff[1])/bmCoeff[0];
      yb2 = ymin;
    } else if (yb2 > ymax) { // yb1 bigger than y max, calculate x based on y max
      xb2 = (ymax-bmCoeff[1])/bmCoeff[0];
      yb2 = ymax;
    } else {
      xb2 = xmax; // else all is good we go with values we got
    }


    if (ransacOn) {
      stroke(colorList[800]);
      strokeWeight(6);
      line(xb1 * distanceOffset, yb1 * distanceOffset, xb2 * distanceOffset, yb2 * distanceOffset);
    }


    dbArray.clear();
  }
  strokeWeight(1);
}

// SERIAL EVENT FUNCTION, CALLED WHEN DATA IS AVAILABLE
//void dealWithSerial() {
//  if (pointArray.size() > maxNumberOfPoints) {
//    for (int i=1; i < serialReadings.size()-2; i++) {
//      pointArray.remove(0);
//    }
//  }

//  if (serialReadings.size()>20) {
//    for (int i=0; i<serialReadings.size()-1; i++) {

//      String data[] = split(serialReadings.get(i), '@');
//      if (data.length==3 && data != null) {

//        //CREATE POINT OBJECT WITH CURRENT DATA
//        int distance = int(data[0]);
//        data[0] = Float.toString(float(data[0]));
//        float angle = float(data[1]);
//        int timeDiff = int(data[2]);
//        if (angle < 10 && lastAngle > 350) {

//          if (timeCounter > 0) {
//            rotFreq = 1/((timeCounter)/1000000);
//            angRes = 360.0/pointCounter;
//          }
//          pointCounter = 0;
//          timeCounter = 0;
//          errorCounter = 0;
//        }

//        pointCounter++;
//        timeCounter = timeDiff + timeCounter;
//        lastTime = timeDiff;
//        lastAngle = angle;

//        if (distance == 1) {
//          errorCounter++;
//        }

//        if (float(data[0]) > filterOut) {
//          Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
//          // ADD POINT OBJECT TO ARRAYLIST
//          pointArray.add(pointObject);
//        }
//      }
//    }
//    serialReadings.clear();
//  }
//}

void serialEvent(Serial p) { 
  try {
    if (counter>500) {
      inString = p.readStringUntil(',');

      String data[] = split(inString, ',');
      serialReadings.add(data[0]);
    } else {
      counter++;
      p.clear();
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
void rectBar(int n) {
  if (n == 1) {
    rectmodeOn = false;
  } else {
    rectmodeOn = true;
  }
}
void clusterPointBar(int n) {
  if (n == 1) {
    clusterPointmodeOn = false;
  } else {
    clusterPointmodeOn = true;
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
    } else if (theEvent.getName() == "minPtsValue") {
      minPts = int(theEvent.getStringValue());
    } else if (theEvent.getName() == "pointArraySizeValue") {
      maxNumberOfPoints = int(theEvent.getStringValue());
    } else if (theEvent.getName() == "Ransac Threshold") {
      ransacThreshold = int(theEvent.getStringValue());
    } else if (theEvent.getName() == "Ransac Hypos") {
      ransacHypos = int(theEvent.getStringValue());
    } else if (theEvent.getName() == "Max Number Of Points") {
      maxNumberOfPoints = int(theEvent.getStringValue());
    }
  }
}

void drawGUIText() {

  int xCoordinator = mouseX - width/2;
  int yCoordinator = mouseY - height/2;

  text("Point Mode", -width/2, -height/2+15);
  text("Cluster Mode", -width/2, -height/2+55);
  text("Line Mode", -width/2, -height/2+95);
  text("Ransac Mode", -width/2, -height/2+135);
  text("Rect Mode", -width/2, -height/2+175);

  text("Rotation Frequency:", -width/2, -height/2 + 485);
  text(nf(rotFreq, 1, 3) + " Hz", -width/2, -height/2 + 500);
  text("Update Frequency:", -width/2, -height/2 + 520);
  text( nf(1/(lastTime/1000000), 1, 3)+ " Hz", -width/2, -height/2 + 535);
  text("Angular Resolution:", -width/2, -height/2 + 555);
  text(nf(angRes, 1, 3) + "°", -width/2, -height/2 + 570);


  text("Number of error MS:", -width/2, -height/2 + 590);
  text(errorCounter, -width/2, -height/2 + 605);

  text("Distance To Mouse:", -width/2, -height/2 + 625);
  float totalDistanceToMouse = sqrt(pow(float(yCoordinator), 2) + pow(float(xCoordinator), 2)) / distanceOffset;
  text(round(totalDistanceToMouse) + " cm", -width/2, -height/2 + 640);
}