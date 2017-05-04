
import processing.serial.*; 

// DECLARE YOUR OBJECTS HERE


// FOR SERIAL READ

Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// DECLARE FOR TEMPORARY STORAGE OF READINGS

ArrayList<String> serialReadings;
int counter=0;
int  numberOfMeasurements=200; 
int wait=0;
int children=0;

FloatList xList;
FloatList yList;

PShape pointGroup;

void setup() {
  size(1000, 1000, P2D); // Size and rendering mode 
  frameRate(120);


  // SERIAL INIT

  comPort = new Serial(this, Serial.list()[0], 115200);
  comPort.bufferUntil(lf);

  // INIT OF STORE TEMPORAL

  serialReadings = new ArrayList<String>();
  
    // initiate lists

  xList = new FloatList();
  yList = new FloatList();
  
  
    // initate shape group
  pointGroup = createShape(GROUP);
}

void draw() {
  background(#000000);
  translate(width/2, height/2);
  //println("number of" + children);
  int dataSize = serialReadings.size()-1;
  //println("size of incoming" + dataSize);
  if(children > 100){
    for (int i=1; i < dataSize; i++) {
      pointGroup.removeChild(0);
    }
  }
  
  if(dataSize > 0){
  for (int i=1; i < dataSize; i++) {   
     println(serialReadings.get(i));      
      String data[] = split(serialReadings.get(i), '@');
      float x = (cos(radians(float(data[1])))*float(data[0])); // gets written to file
      float y = (sin(radians(float(data[1])))*float(data[0])); // gets written to file  
    // println(data[2]); // gets written to file

    PShape rectangle = createShape(RECT, x, y, 4, 4);
    rectangle.setFill(false);
    rectangle.setStroke(color(#0CF015)); // change color for outline
    pointGroup.addChild(rectangle); // add to grouped
    
  }
  children = pointGroup.getChildCount(); // store current number of childre
  }
  serialReadings.clear();
  shape(pointGroup);
}

void serialEvent(Serial p) { 
  try {
    wait++;
    if (wait>10){
    inString = p.readStringUntil(',');
    String data[] = split(inString, ',');
    serialReadings.add(data[0]);
    }
    else{
     //  p.clear();
    }
  }
  catch(RuntimeException e) {
  }
}