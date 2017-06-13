/**
  Read the string from the serial buffer function  and convert each reading into a point object added to a point object arraylist with a x and y coordinate and relative birth time
  @return void
**/
void readSerial() {
  if (serialReadings.size()>maxNumberOfPoints) {
    bgPointArray.clear();
    pointArray.clear();
    for (int i=0; i<serialReadings.size(); i++) {
      if (serialReadings.get(i) != "null") {
        String data[] = split(serialReadings.get(i), '@'); // split based on delimiter
        
        //CREATE POINT OBJECT WITH CURRENT DATA
        int distance = int(data[0]);
        data[0] = Float.toString(float(data[0]));
        float angle = float(data[1]);
        int timeDiff = int(data[2]);
        
        // caluclate angular frequency and angular resulotion for display
        if (angle < 10 && lastAngle > 350) {
          if (timeCounter > 0) {
            rotFreq = 1/((timeCounter)/1000000);
            angRes = 360.0/pointCounter;
          }
          pointCounter = 0;
          timeCounter = 0;
          errorCounter = 0;
        }

        pointCounter++;
        timeCounter = timeDiff + timeCounter;
        lastTime = timeDiff;
        lastAngle = angle;

        if (distance == 1) { // we count faulty readings for display
          errorCounter++;
        }

        if (float(data[0]) < 1000 && float(data[0]) != 1) { // only add stuff thats not one and smaller than 1000 (outlier and faulty readings removal)
          Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
          pointArray.add(pointObject);
        }
      }
    }
    serialReadings.clear();
  }
}