import java.util.Collections; // For sorting
import processing.serial.*; 


int m,b,ransacHypos, ransacThreshold; // Ransac
int eps, minPts,clusterCount; //   DBSCAN

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
int maxNumberOfPoints=360;

// COLORS AND GUI

color[] colorList; 
int noc;
color bgColor;


// FOR OFFSET IN PLOTTER
float angleOffset = 150;
float distanceOffset = 1;


// FOR COMPARETO

int xory=0; // Sort ascending X/Y. 0/1

 // FOR BUTTONS AND GUI
 
 PShape b1,b2,b3,b4,b5,b6;
 PShape buttonGroup;


void setup(){
  size(1000,1000); // canvas size
  surface.setResizable(true);
  // FOR RANSAC
  
  ransacHypos = 200; // Ransac lines to try
  ransacThreshold = 10; // Inliner threshold
  
  // FOR DBSCAN
  
  eps = 25; // epsilon, distance between points for cluster
  minPts = 3; // minimum points to create cluster
  clusterCount=0; // how many clusters in data set
  
  // FOR COLORS
  
  noc = 1000; // number of colors
  colorList = new color[noc]; // color array
  
  for (int i=0;i<1000; i++) // Populate color array with random colors
  {
    colorList[i] = color(random(0,255), random(0,255), random(0,255));
  }
  
  bgColor=40;
  

  
  
  // FOR DATA
  
  filterOut=10; // filter out measurements closer than filterOut
  
 //SERIAL INIT
   
  comPort = new Serial(this, Serial.list()[1], 115200);
  comPort.bufferUntil(lf);
  serialReadings = new ArrayList<String>();
 
 // FOR BUTTONS
 buttonGroup = createShape(GROUP);
 
 b1 = createShape(RECT,0,0,80,80);
 b1.setStroke(#FFFFFF);
 b1.setFill(bgColor);
 buttonGroup.addChild(b1);
 
 b2 = createShape(RECT,80,0,80,80);
 b2.setStroke(#FFFFFF);
 b2.setFill(bgColor);
 buttonGroup.addChild(b2);
 
}

void draw(){
  background(bgColor); // background color
  translate(width/2, height/2); // translate origin to middle
  
  int paSize = pointArray.size(); // store the size for use 
  
  dealWithSerial(); // DO IT
  
 if (pointArray.size() > 100){ 
  
  
  DBSCAN(pointArray); // DBSCAN points for clustering DBSCAN gives each point in set a clusterID

// draw point chart 

   drawPoints();

// draw line connected point chart
  
  //drawConnectedPoints();


// Build individual point clouds based on cluster ID

for(int j=1; j< clusterCount-1;j++){ // minus one

  ArrayList<Point> dbArray = new ArrayList<Point>(); // collect clusters
  for(int i=0; i < pointArray.size();i++){ // minus one
      if (pointArray.get(i).getClusterID()==j){
          dbArray.add(pointArray.get(i));
       }
  }
  
  if (dbArray.size() > 10){
  
    Collections.sort(dbArray); // sort array on X ascending
    
    drawClusterConnectedPoints(dbArray); // draw line connected point chart based on cluster
    
     drawRansacCluster(dbArray); // draw RANSAC lines based on clusters
  }
  }
 }
// END OF FILE
  
  translate(-width/2,-height/2);
  println(b2.getVertexCount());
  shape(buttonGroup);

}

void drawPoints(){
    for(int i=0; i < pointArray.size(); i++)
  {
    color clusterColor = (colorList[pointArray.get(i).getClusterID()]);
    stroke(clusterColor);
    if(pointArray.get(i).getClusterID()==0){
      noFill();
      // ellipse(pointArray.get(i).getX(),pointArray.get(i).getY(), 20,20);
    }
    else
    {
      fill(clusterColor);
      rect(pointArray.get(i).getX(),pointArray.get(i).getY(), 5,5);
    }  
}
}


void drawConnectedPoints(){
  for(int i=0; i < pointArray.size()-1;i++){ // draw point connected chart
    stroke(colorList[800]);
    strokeWeight(1);
    line(pointArray.get(i).getX(),pointArray.get(i).getY(),pointArray.get(i+1).getX(),pointArray.get(i+1).getY());
  }
}

// draw cluster points connected charts

void drawClusterConnectedPoints(ArrayList<Point> dbArray){
  for(int i=0; i < dbArray.size()-1;i++){ 
    stroke(colorList[i]);
    strokeWeight(4);
    line(dbArray.get(i).getX(),dbArray.get(i).getY(),dbArray.get(i+1).getX(),dbArray.get(i+1).getY());
  }
}


void drawRansacCluster(ArrayList<Point> dbArray){
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
  }
  else if (yb1 > ymax)
  { // yb1 bigger than y max, calculate x based on y max
    xb1 = (ymax-bmCoeff[1])/bmCoeff[0];
    yb1 = ymax;
  }
  else
  {
    xb1 = xmin; // else all is good we go with values we got
  }
  
  float xb2;
  if (yb2 < ymin)
  { // yb1 less than y min, calculate x based on y min
    xb2 = (ymin-bmCoeff[1])/bmCoeff[0];
    yb2 = ymin;
  }
  else if (yb2 > ymax)
  { // yb1 bigger than y max, calculate x based on y max
    xb2 = (ymax-bmCoeff[1])/bmCoeff[0];
    yb2 = ymax;
  }
  else
  {
    xb2 = xmax; // else all is good we go with values we got
  }
  
    strokeWeight(4);
    stroke(colorList[800]);
    line(xb1,yb1,xb2,yb2);
  

}


// BUTTONS

void drawButtons(){

}


// SERIAL EVENT FUNCTION, CALLED WHEN DATA IS AVAILABLE

void dealWithSerial(){
  if (pointArray.size() > maxNumberOfPoints) {
    for (int i=1; i < serialReadings.size()-2; i++) {
      pointArray.remove(0);
    }
  }
  
  if (serialReadings.size()>20) {
    for (int i=0; i<serialReadings.size()-2; i++) {

      String data[] = split(serialReadings.get(i), '@');
      if (data.length==3 && data != null) {
          
        //CREATE POINT OBJECT WITH CURRENT DATA
        // data[0] = Float.toString(map(float(data[0]), 0, 1000, 0, distanceOffset));
        if (float(data[0]) > filterOut){
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

//boolean overButton()  {
 // if (mouseX >= b1.getVertex(0).x && mouseX <= b1.getVertex(0).x && 
   //   mouseY >= b1.getVertex(0).y && mouseY <= b1.getVertex(0).y) {
   // return true;
 // } else {
 //   return false;
 // }
//}