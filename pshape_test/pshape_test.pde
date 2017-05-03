import processing.serial.*; 

// FOR SERIAL

Serial myPort;    // The serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed 

// FOR PHSAPE DRAWING
PShape radarLine;
FloatList distanceList, angleList, xList, yList; // floatlists for point data
Float lastX=0.0;
Float lastY=0.0;
PShape group;
int radarPos=0;

// FOR RANSAC

ArrayList<PVector> pvectorList = new ArrayList<PVector>(); // for RANSAC
int hypoLines=40; // 
int threshold=5;


void setup() {

  size(1000, 1000, P2D); // Size and rendering mode 
  frameRate(120);
  // serial init

  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.bufferUntil(lf);

  // initiate lists

  distanceList = new FloatList();
  angleList = new FloatList();
  xList = new FloatList();
  yList = new FloatList();

  // initate shape group
  group = createShape(GROUP);
}

void draw() {

  background(#000000);
  translate(width/2, height/2); // origin in center

  if (angleList.size()>1) { // fix condition to have something to shape  

    // convert from polar to cartesian and create plist
    
    for (int i=0; i<angleList.size()-1; i++) {
      float x = (distanceList.get(i) * cos(angleList.get(i)));
      float y = -(distanceList.get(i) * sin(angleList.get(i)));
        
      pvectorList.add(new PVector(x, y)); // add for ransac
      xList.append(x); // add for clear shape and coordinate shapes
      yList.append(y);
    }
    
    // store last last elements for cleanse
    
    lastX= xList.get(xList.size()-1);
    lastY= yList.get(yList.size()-1);
    
    // here a triangle get cleared for new values
    PShape pieClear;
    pieClear = createShape();
    pieClear.beginShape();
    pieClear.fill(#000000);
    int lastElement = xList.size()-1;
    pieClear.vertex(0, 0); 
    pieClear.vertex(lastX, lastY);
    pieClear.vertex(xList.get(lastElement), yList.get(lastElement));
    pieClear.endShape();
     //pieClear.setStroke(#FFFFFF);
    group.addChild(pieClear); // add shape to group
    
    
        // here the radar line shape is created
    group.removeChild(radarPos);
    
    radarLine =  createShape(LINE, 0, 0, xList.get(lastElement), yList.get(lastElement));;
    radarLine.setFill(false);
    radarLine.setStroke(color(#0CF015));
    //group.addChild(radarLine); // add shape to group
    //radarPos = group.getChildCount()-1;

    

    // ransac gets created here (commented out for debug)

      ArrayList<PVector> pvectorListRansac = new ArrayList<PVector>();
      pvectorListRansac = getRansac(pvectorList);
      PShape pshapeRansac;
      pshapeRansac = createShape(LINE,pvectorListRansac.get(0).x,pvectorListRansac.get(0).y,pvectorListRansac.get(1).x,pvectorListRansac.get(1).y);
      pshapeRansac.setStroke(#FFFFFF);
      
      group.addChild(pshapeRansac);
  }

  // here the coordinates get turned into rectangles and added to the pshape group

  for (int i=0; i<xList.size()-1; i++) {
    PShape rectangle = createShape(RECT, xList.get(i), yList.get(i), 4, 4);
    rectangle.setFill(false);
    rectangle.setStroke(color(#0CF015)); // change color for outline
    group.addChild(rectangle); // add to grouped
  }

  // set how many children we allow to group, remove latest if above threshold

  if (group.getChildCount()>360) { 
    for (int i=0; i<xList.size()+1; i++) {
      group.removeChild(0);
    }
  }

  // clean up the list 

  distanceList.clear();
  angleList.clear();
  xList.clear();
  yList.clear();

  println(group.getChildCount()); // for debug, nubmer of pshapes (coordinates, pieclears)
  shape(group); //display the group
  shape(radarLine,0,0);
}




// RANSAC FUNCTION, not used now

ArrayList<PVector> getRansac(ArrayList<PVector> pvIN) {

  // we declare a arraylist to store our ransac line 
  ArrayList<PVector> ransacLine = new ArrayList<PVector>();
  ransacLine.add(new PVector(0, 0));
  ransacLine.add(new PVector(0, 0));

  int inlineCounter=0, bestInlineCount=0;

  // We test set number of lines
  for (int i=0; i<hypoLines-1; i++) {
    // we clone our inlist to make some stoof with it
    ArrayList<PVector> pvInClone = new ArrayList<PVector>();
    pvInClone = (ArrayList<PVector>)pvIN.clone(); // clone indata

    // first we create hypo line and remove the points we take from it.
    int randP1 = int(random(0, pvIN.size()-1)); // take a random point from data
    PVector point1;
    point1 = new PVector(pvIN.get(randP1).x, pvIN.get(randP1).y);

    PVector point2;
    int randP2= int(random(0, pvIN.size()-1)); // and another random point
    point2 = new PVector(pvIN.get(randP2).x, pvIN.get(randP2).y);
    // //println("second rand: " + pvIN.get(randP2)); // debug
    if (pvInClone.size()>0) {
      pvInClone.remove(randP2); // remove it
    }


    if (abs(point2.x - point1.x) < 100) {

      // then we check the distance for each point to this line
      for (int j=0; j<pvIN.size()-2; j++) {

        float m = (point2.y - point1.y) / (point2.x - point1.x);
        float b = point1.y - m * point1.x;      
        double distance = abs(pvInClone.get(j).y - m * pvInClone.get(j).x - b) / sqrt(1 + m * m); 
        float d = (float)distance;

        if (d < threshold) { // count inliners
          inlineCounter++;
        }
      }
    }


    // if the count was good (higher than last line) we store the the ransac line points and the inline count value as best value

    if (inlineCounter > bestInlineCount) {
      ransacLine.set(0, point1);
      ransacLine.set(1, point2);
      bestInlineCount = inlineCounter;
    }

    inlineCounter = 0 ; // reset inline counter
  }

  // when all is done we return the ransac line
  pvectorList.clear();
  return ransacLine;
}



void serialEvent(Serial p) { 
  try {
    inString = p.readStringUntil('\n');

    if (inString.indexOf('&') != -1) { 
      String[] data= split(inString, '&');
      if (inString != null) {
        float angle = radians(float(data[1]));  
        float distance = float(data[0]);
        distance = map(distance, 0, 600, 0, 600);
        // println(data[0]);

        if (distance > 0) {
          distanceList.append(distance);
          angleList.append(angle);
        }

        p.clear();
      }
    }
  }
  catch(RuntimeException e) {
  }
}