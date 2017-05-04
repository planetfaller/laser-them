  
import processing.serial.*; 

// DECLARE YOUR OBJECTS HERE

PrintWriter output;

// FOR SERIAL READ

Serial comPort;    // The serial port
String inString;  // Input string
int lf = 84;      // ASCII delimiter ","

// DECLARE FOR TEMPORARY STORAGE OF READINGS

FloatList distance,position,timestamp;
int counter=0;
int  numberOfMeasurements=1000; 


void setup() {
  size(500, 500); 
  
  // Create a new file in the sketch directory
  output = createWriter("data.dat"); 
  
  // SERIAL INIT

  comPort = new Serial(this, Serial.list()[0], 115200);
  comPort.bufferUntil(lf);

  // INIT OF STORE TEMPORAL
  
  distance = new FloatList(); 
  
}

void draw() {
  for (int i=0; i < distance.size()-1; i++){
      output.print(distance.get(i) + ","); // gets written to file
      print(distance.get(i) + ","); // gets written on screen
}
  distance.clear();
}

void serialEvent(Serial p) { 
  try {
    inString = p.readStringUntil('T');
        String data[] = split(inString, 'D'); // splits into substrings for relevant values
        String data1[] = split(data[1], 'P'); 
        String data2[] = split(data1[1], 'T'); 
        distance.append(float(data2[0])); // choose value here
        p.clear();
        counter++;
        if(counter>numberOfMeasurements-1){
          output.flush();  // Writes the remaining data to the file
          output.close();  // Finishes the file
          exit();  // Stops the program
        }
  }
  catch(RuntimeException e) {
  }
}