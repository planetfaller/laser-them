  
import processing.serial.*; 

// DECLARE YOUR OBJECTS HERE

PrintWriter output;


// FOR SERIAL READ

Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// DECLARE FOR TEMPORARY STORAGE OF READINGS

ArrayList<String> serialReadings;
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
  
  serialReadings = new ArrayList<String>(); 

}

void draw() {
  int dataSize = serialReadings.size()-1;
  for (int i=1; i < dataSize; i++){
      output.print(serialReadings.get(i) + ","); // gets written to file
        String data[] = split(serialReadings.get(i), '@');
        println(data[0]);
        println(data[1]);
        println(data[2]);
  }
  serialReadings.clear();
}

void serialEvent(Serial p) { 
  try {
    
    counter++;
    
    if(counter>0){
    inString = p.readStringUntil(',');
        String data[] = split(inString, ',');
        serialReadings.add(data[0]);
         
        if(counter>numberOfMeasurements-1){
          output.flush();  // Writes the remaining data to the file
          output.close();  // Finishes the file
          exit();  // Stops the program
        }
    }
  }
  catch(RuntimeException e) {
  }
}