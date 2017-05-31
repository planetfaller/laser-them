void setup(){
readData();

}

void draw(){}


void readData(){
String[] inStringRaw = loadStrings("dataDPTnull.dat");
// String inString = inStringArray[0];

String inStringReading[] = split(inStringRaw[0],','); 

  for (int i=0;i<inStringReading.length; i++){
    if (!(inStringReading[i] == "null")){
      String data[] = split(inStringReading[i],'@');
      println(data[0]);
      if (inStringReading[i].equals("null")){
        println("FUCKOFF");
      }
      // println(data[1]);
      // println(data[2]);
    }
  } 
}