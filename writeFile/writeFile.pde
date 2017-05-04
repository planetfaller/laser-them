
import processing.serial.*; 

// DECLARE YOUR OBJECTS HERE

PrintWriter dataDPT, dataD, dataP, dataT;


// FOR SERIAL READ

Serial comPort;    // The serial port
String inString;  // Input string
int lf = 44;      // ASCII delimiter ","

// DECLARE FOR TEMPORARY STORAGE OF READINGS

ArrayList<String> serialReadings;
int counter=0;
int  numberOfMeasurements=200; 
int wait=0;


void setup() {
  size(500, 500); 

  // Create a new file in the sketch directory
  dataDPT = createWriter("dataDPT.dat");
  dataD = createWriter("dataD.dat"); 
  dataP = createWriter("dataP.dat"); 
  dataT = createWriter("dataT.dat");


  // SERIAL INIT

  comPort = new Serial(this, Serial.list()[0], 115200);
  comPort.bufferUntil(lf);

  // INIT OF STORE TEMPORAL

  serialReadings = new ArrayList<String>();
}

void draw() {
  int dataSize = serialReadings.size()-1;
  if(dataSize > 0){
  for (int i=1; i < dataSize; i++) {   
    
    if (counter>numberOfMeasurements-1) {
      dataDPT.flush();  // Writes the remaining data to the file
      dataDPT.close();  // Finishes the file          dataDPT.flush();  // Writes the remaining data to the file
      dataD.flush();  // Finishes the file          dataDPT.flush();  // Writes the remaining data to the file
      dataD.close();  // Finishes the file          dataDPT.flush();  // Writes the remaining data to the file
      dataP.flush();  // Finishes the file          dataDPT.flush();  // Writes the remaining data to the file
      dataP.close();  // Finishes the file
      dataT.flush();  // Finishes the file          dataDPT.flush();  // Writes the remaining data to the file
      dataT.close();  // Finishes the file
      exit();  // Stops the program
    } else {
      counter++;

      dataDPT.print(serialReadings.get(i) + ","); // gets written to file
      println(serialReadings.get(i));

      String data[] = split(serialReadings.get(i), '@');
      //println(data[0]);
      //dataD.print(data[0] + ","); // gets written to file    
      //println(data[1]);
      //dataP.print(data[1] + ","); // gets written to file  
      //println(data[2]);
      
      dataD.print(cos(radians(float(data[1])))*float(data[0]) + ","); // gets written to file
      dataP.print(sin(radians(float(data[1])))*float(data[0]) + ","); // gets written to file  
      
      dataT.print(data[2] + ","); // gets written to file
    }
  }
  serialReadings.clear();
}
}

void serialEvent(Serial p) { 
  try {
    wait++;
    if (wait>1000){
    inString = p.readStringUntil(',');
    String data[] = split(inString, ',');
    serialReadings.add(data[0]);
    }
    else{
      p.clear();
    }
  }
  catch(RuntimeException e) {
  }
}