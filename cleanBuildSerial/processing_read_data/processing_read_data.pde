/**
  360 Degree Rotating LiDAR Lite 3 point cloud data analyzer and visualizer
  Name: processing_read_data
  Purpose: To analyze and visualize 2 dimensional LiDAR point cloud data recieved thorugh serial interface from an Arduino
  GUI Code based on : http://www.sojamo.de/libraries/controlP5/
  @author Rickard Lind & Simon Ask
  @version 1.0 20/05/17
*/

import controlP5.*; // ControlP5 required install via tools --> add tools --> libraries --> search
import java.util.Collections; // For sorting
import processing.serial.*; // Serial communication

// COUNTS
float timeCounter=0;
int pointCounter=0;
int errorCounter = 0;
float lastAngle = 0;
float rotFreq=0;
float lastTime=1000;
float angRes=0;

// OCCUPY GRID

int[][] grid = new int[100][100]; // create a hundred by hundred occupy grid



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
ArrayList<Point> bgPointArray = new ArrayList<Point>(); // Data input array

int filterOut;

// FOR SERIAL
Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// DECLARE FOR TEMPORARY STORAGE OF READINGS
FloatList distance, position, timestamp;
int counter=0;
ArrayList<String> serialReadings;
int maxNumberOfPoints=150;

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

  // Create GUI object
  cp5 = new ControlP5(this);

  //Buttonbar for Point Mode
  ButtonBar onlyPointBar = cp5.addButtonBar("onlyPointBar")
    .setPosition(0, 20)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  onlyPointBar.changeItem("a", "text", "On");
  onlyPointBar.changeItem("b", "text", "Off");

  //Buttonbar for Cluster Mode
  ButtonBar clusterPointBar = cp5.addButtonBar("clusterPointBar")
    .setPosition(0, 60)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  clusterPointBar.changeItem("a", "text", "On");
  clusterPointBar.changeItem("b", "text", "Off");

  //Buttonbar for Line Mode
  ButtonBar lineBar = cp5.addButtonBar("lineBar")
    .setPosition(0, 100)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  lineBar.changeItem("a", "text", "On");
  lineBar.changeItem("b", "text", "Off");

  //Buttonbar for Ransac Mode
  ButtonBar ransacBar = cp5.addButtonBar("ransacBar")
    .setPosition(0, 140)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  ransacBar.changeItem("a", "text", "On");
  ransacBar.changeItem("b", "text", "Off");

  //Buttonbar for Rect Mode, object detection.
  ButtonBar rectBar = cp5.addButtonBar("rectBar")
    .setPosition(0, 180)
    .setSize(100, 20)
    .addItems(split("a b", " "));
  rectBar.changeItem("a", "text", "On");
  rectBar.changeItem("b", "text", "Off");

  //Slider for angle offset
  cp5.addSlider("AngleOffsetSlider")
    .setRange(0, 360)
    .setCaptionLabel("Angle Offset")
    .setValue(0)
    .setPosition(0, height-20)
    .setSize(100, 10);

  //Slider for distance scale
  cp5.addSlider("DistanceOffsetSlider")
    .setRange(0.1, 1.5)
    .setCaptionLabel("Distance Scale")
    .setValue(1)
    .setPosition(0, height-40)
    .setSize(100, 10);

  //Textfields for variable inputs.
  cp5.addTextfield("Max Number Of Points")
    .setPosition(0, 220)
    .setText("150")
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

  //Circles around the construction for distance reference, scales with slider.
  ellipse(0, 0, 200 * distanceOffset, 200 * distanceOffset);
  ellipse(0, 0, 600 * distanceOffset, 600 * distanceOffset);
  ellipse(0, 0, 1000 * distanceOffset, 1000 * distanceOffset);
  ellipse(0, 0, 2000 * distanceOffset, 2000 * distanceOffset);

  //Visualize the construction in the GUI, scales with slider.
  fill(100);
  rect(-15*distanceOffset, -15*distanceOffset, 30*distanceOffset, 30*distanceOffset);
  fill(#ffffff);

  //Visualize variables in GUI
  drawGUIText();

  if (pointArray.size() > 3) {

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

/**
  Draws all the points read and stored

  @return void
*/
void drawOnlyPoints() {
  for (int i = 0; i < pointArray.size(); i++) {
    stroke(#ffffff);
    ellipse(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, 2, 2);
  }
}

/**
  Draw points in cluster, with cluster color

  @return void
*/
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
      // text(str(pointArray.get(i).getClusterID()), pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset); // points
      rect(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, 4, 4);
    }
  }
}


/**
  Draws lines between all points currently stored

  @return void
*/
void drawConnectedPoints() {
  stroke(colorList[800]);
  for (int i=0; i < pointArray.size()-1; i++) { // draw point connected chart
    line(pointArray.get(i).getX() * distanceOffset, pointArray.get(i).getY() * distanceOffset, pointArray.get(i+1).getX() * distanceOffset, pointArray.get(i+1).getY() * distanceOffset);
  }
}

/**
  Draws lines between points based on cluster, currently not working well

  @return void
*/
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


/**
  Calculates a RANSAC line for each cluster, calls getRansac(), and draws the lines

  @return void
**/
void drawRectRansac() {
  // Build individual point clouds based on cluster ID
  ArrayList<Point> dbArray = new ArrayList<Point>(); // collect clusters
  for (int i=1; i <= currentNumberOfClusters; i++) { // minus one 
    for (int j=0; j < pointArray.size()-1; j++) { // minus one
      if (pointArray.get(j).getClusterID()==i) {
        dbArray.add(pointArray.get(j));
      }
    }

    xory=0; // sort on x
    Collections.sort(dbArray); // sort array on X ascending
    float xmax = dbArray.get(dbArray.size()-1).getX(); // get min and max x for each cluster
    float xmin = dbArray.get(0).getX(); 

    xory=1; // sort on y
    Collections.sort(dbArray); // sort array on Y ascending   
    float ymax = dbArray.get(dbArray.size()-1).getY(); // get min and max y for each cluster
    float ymin = dbArray.get(0).getY();

    if (rectmodeOn) { // if rectmode is on from GUI we draw a rectangel
      stroke(#ff0000);
      noFill();
      rect(xmin * distanceOffset, ymin * distanceOffset, (xmax-xmin) * distanceOffset, (ymax-ymin) * distanceOffset);
    }

    if (ransacOn) { // if RANSAC is on, we also calculate and draw the RANSAC line 
      float[] bmCoeff =  new float[2];
      bmCoeff = getRansac(dbArray, ransacHypos, ransacThreshold); // get RANSAC coefficients
  
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
  
      stroke(colorList[800]);
      strokeWeight(4);
      line(xb1 * distanceOffset, yb1 * distanceOffset, xb2 * distanceOffset, yb2 * distanceOffset);
    }
    strokeWeight(1);

    dbArray.clear();
  }
}


/**
  serialEvent gets called when we have serial event
  
  @param {Serial} p serial object
  @return void
*/
void serialEvent(Serial p) { 
  try {
    if (counter>500) {
      inString = p.readStringUntil(',');
      String data[] = split(inString, ','); // split on delimiter, CSV
      serialReadings.add(data[0]);
    } else {
      counter++;
      p.clear();
    }
  }
  catch(RuntimeException e) {
  }
}

/**
  Starts or stops ransac mode.

  @return void
**/
void ransacBar(int n) {
  if (n == 1) {
    ransacOn = false;
  } else {
    ransacOn = true;
  }
}
/**
  Starts or stops line mode.

  @return void
**/
void lineBar(int n) {
  if (n == 1) {
    linemodeOn = false;
  } else {
    linemodeOn = true;
  }
}
/**
  Starts or stops rect mode.

  @return void
**/
void rectBar(int n) {
  if (n == 1) {
    rectmodeOn = false;
  } else {
    rectmodeOn = true;
  }
}
/**
  Starts or stops cluster mode.

  @return void
**/
void clusterPointBar(int n) {
  if (n == 1) {
    clusterPointmodeOn = false;
  } else {
    clusterPointmodeOn = true;
  }
}
/**
  Starts or stops point mode.

  @return void
**/
void onlyPointBar(int n) {
  if (n == 1) {
    onlyPointmodeOn = false;
  } else {
    onlyPointmodeOn = true;
  }
}

/**
  Changes the angle offset in the GUI with a slider event.

  @return slider value
**/
public void AngleOffsetSlider(float myOffset) {
  angleOffset = myOffset;
}

/**
  Changes the distance scale in the GUI with a slider event.

  @return distance scale value
**/
public void DistanceOffsetSlider(float myOffset) {
  distanceOffset = myOffset;
}


/**
  Changes algorithm variables with textfield object.

  @param eps, epsilon value for DBSCAN
  @param minPts value for DBSCAN
  @param maxNumberOfPoints for DBSCAN
  @param ransacThreshold for RANSAC
  @param ransacHypos for RANSAC
  @param maxNumberOfPoints for RANSAC
  @return eventStringValue.
**/
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

/**
  Visualizes varialbes in GUI.

  @return void
**/
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
  
  text("Measurments/Rotation:", -width/2, -height/2 + 590);
  text(nf(360.0/angRes, 1, 3), -width/2, -height/2 + 605);

  text("Number of error MS:", -width/2, -height/2 + 625);
  text(errorCounter, -width/2, -height/2 + 640);

  text("Distance To Mouse:", -width/2, -height/2 + 655);
  float totalDistanceToMouse = sqrt(pow(float(yCoordinator), 2) + pow(float(xCoordinator), 2)) / distanceOffset;
  text(round(totalDistanceToMouse) + " cm", -width/2, -height/2 + 670);
  
}