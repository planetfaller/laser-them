void readSerial() {
  //println(serialReadings.size());
  //if (pointArray.size()>160){
  //       for (int i=0;i < serialReadings.size();i++){
  //         pointArray.remove(0);
  //       }  
  //}

  if (serialReadings.size()>maxNumberOfPoints) {
    bgPointArray.clear();
    pointArray.clear();
    for (int i=0; i<serialReadings.size(); i++) {
      if (serialReadings.get(i) != "null") {
        String data[] = split(serialReadings.get(i), '@');

        //CREATE POINT OBJECT WITH CURRENT DATA
        int distance = int(data[0]);
        data[0] = Float.toString(float(data[0]));
        float angle = float(data[1]);
        int timeDiff = int(data[2]);
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

        if (distance == 1) {
          errorCounter++;
        }



        if (float(data[0]) < 1000 && float(data[0]) != 1) { // only add stuff thats smallahr than 10

          Point pointObject = new Point((cos(radians(float(data[1])+angleOffset))*(float(data[0]))), (sin(radians(float(data[1])+angleOffset))*(float(data[0]))), float(data[2]), color(random(150), random(255), random(255)), pointArray.size()-1);
          // pointArray.add(pointObject);
          // ADD POINT OBJECT TO ARRAYLIST


          //println(int(pointObject.getX()+1000)/20);
          //println(pointObject.getY()+1000);
          if (grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]< 4) { // populate the grid, readings get added until 

            if (grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] < 6){
              grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] = grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] + 2;  //grid[int(pointObject.getX()+1000)/50][int(pointObject.getY()+1000)/50]+1;
            // println( grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]);
              pointArray.add(pointObject);
            // println(pointArray.size());
            }
          } 
          if (grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] > 3) {
            if (grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] < 6){  
            grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] = grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20] +1;
            }
            bgPointArray.add(pointObject);
          }
        }
      }
    }

    //if (grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]>0){
    //  grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]=grid[int(pointObject.getX()+1000)/20][int(pointObject.getY()+1000)/20]-1;
    //}



    for (int k=0; k<100; k++) {
      for (int j=0; j < 100; j++) {
        
        if (grid[k][j]>0) {
          grid[k][j] = grid[k][j] - 1;
        }
      }
    }

    serialReadings.clear();
  }
  //serialReadings.clear();
}