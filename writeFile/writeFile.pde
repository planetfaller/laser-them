  
import processing.serial.*; 
PrintWriter output;

int counter=0;
int  numberOfMeasurements=1000; 

// FOR SERIAL

Serial myPort;    // The serial port
String inString;  // Input string from serial port
int lf = 44;      // ASCII linefeed 

// DECLARE FOR TEMPORARY STORAGE OF READINGS

FloatList distance;

void setup() {
  size(500, 500); 
  
  // Create a new file in the sketch directory
  output = createWriter("data.dat"); 
  
  // SERIAL INIT

  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.bufferUntil(lf);

  // INIT OF STORE TEMPORAL
  
  distance = new FloatList(); 
  
}

void draw() {
  for (int i=0; i < distance.size()-1; i++){
    if (counter<numberOfMeasurements-1){
    output.print(distance.get(i) + ",");
    print(distance.get(i) + ",");
    } else if (counter <numberOfMeasurements){
      output.print(distance.get(i));
      print(distance.get(i));
      output.flush();  // Writes the remaining data to the file
      output.close();  // Finishes the file
      exit();  // Stops the program
    }
}
  distance.clear();
}

//void keyPressed() {
//  output.flush();  // Writes the remaining data to the file
//  output.close();  // Finishes the file
//  exit();  // Stops the program
//}

void serialEvent(Serial p) { 
  try {
    inString = p.readStringUntil(',');
        String data[] = split(inString, ',');
        distance.append(float(data[0]));
        p.clear();
        counter++;
  }
  catch(RuntimeException e) {
  }
}