void readData() {
  String[] inStringRaw = loadStrings("dataDPT.dat");
  // String inString = inStringArray[0];

  String inStringReading[] = split(inStringRaw[0], ','); 

  for (int i=0; i<4000; i++) { // inStringReading.length
    if (!inStringReading[i].equals("null")) {
      String data[] = split(inStringReading[i], '@');

      if (float(data[0]) < 2000 && float(data[0]) != 1) { // only add stuff thats smallahr than 10

        Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
        // ADD POINT OBJECT TO ARRAYLIST


        //println(int(pointObject.getX()+1000)/20);
        //println(pointObject.getY()+1000);
        if (grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]<8) { // populate the grid, readings get added until 
          grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]=grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]+1;
          println( grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]);
          pointArray.add(pointObject);
        }
      }
    }
  }  




  println(pointArray.size());
}