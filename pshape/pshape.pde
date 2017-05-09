
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
  
        if(pointGroup.getChildCount() > 300){
            for (int i=1; i < serialReadings.size()-2; i++) {
            pointGroup.removeChild(0);
            }
          }
      
      if (serialReadings.size()>20){
        println(serialReadings.size());
        for(int i=0; i<serialReadings.size()-2;i++){
          // println(serialReadings.get(i));
          String data[] = split(serialReadings.get(i), '@');
          
          
          if(data.length==3){
            float x = (cos(radians(float(data[1])))*float(data[0]));
            float y = (sin(radians(float(data[1])))*float(data[0]));  
            PShape rectangle = createShape(RECT, x, y, 4, 4);
            rectangle.setFill(color(random(255), random(255), random(255), random(255)));
            rectangle.setStroke(color(random(255), random(255), random(255), random(255))); // change color for outline
            rectangle.setStroke(#0BAF00); // change color for outline
            pointGroup.addChild(rectangle); // add to grouped
          }
        }
        serialReadings.clear();
      }
      shape(pointGroup);
}

void serialEvent(Serial p) { 
  try {
        wait++;
    if (wait>100){
    inString = p.readStringUntil(',');
    String data[] = split(inString, ',');
        serialReadings.add(data[0]);
    }  
  }
    catch(RuntimeException e) {
  }
}