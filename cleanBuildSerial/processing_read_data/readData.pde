/**
 Reads stored data from a text file and stores it the global arraylist of points. Used for debug and analysis.
 
 @return void
 **/
void readData() {
  String[] inStringRaw = loadStrings("dataDPT.dat"); // read text adn store in string
  String inStringReading[] = split(inStringRaw[0], ','); // split based on delimiter, CSV

  for (int i=0; i<4000; i++) { // inStringReading.length
    if (!inStringReading[i].equals("null")) {
      String data[] = split(inStringReading[i], '@'); // split based on delimiter
      if (float(data[0]) < 2000 && float(data[0]) != 1) { // only add stuff thats not one and smaller than 2000 (outlier and faulty readings removal)
        // add as a point object in arraylist 
        Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
        pointArray.add(pointObject); // add to kust
      }
    }
  }  
}