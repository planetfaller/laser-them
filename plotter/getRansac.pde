ArrayList<Point> getRansac(ArrayList<Point> inPA, int numberOfHypo, int threshold){


    // we declare a arraylist to store our ransac line 
    ArrayList<Point> ransacLine = new ArrayList<Point>();
    //ransacLine.add(inPA.get(0));
    //ransacLine.add(inPA.get(0));
    Point point1, point2;
    
    
    int inlineCounter=0, bestInlineCount=0;

    // We test set number of lines
  for(int i=0;i<numberOfHypo;i++){
    // we clone our inlist to make some stoof with it
    ////println(pvIN);
    //println("pvIn.size" + pvIN.size());
    ArrayList<Point> inPAClone = new ArrayList<Point>();
    inPAClone = (ArrayList<Point>)inPA.clone(); // clone indata
    //println("pvInClone.size" + pvInClone.size());
    // first we create hypo line and remove the points we take from it.
    int randP1 = int(random(0,inPA.size()-1)); // take a random point from data
    
    
    point1 = new Point(inPA.get(randP1).getX(), inPA.get(randP1).getY());
    inPAClone.remove(randP1); // remove it
    //pvectorListPie("point1" + point1);
    
    //println("pvinclone size " + pvInClone);
    
    int randP2= int(random(0,inPA.size()-1)); // and another random point
    point2 = new Point(inPA.get(randP2).getX(), inPA.get(randP2).getY());
    // //println("second rand: " + pvIN.get(randP2)); // debug
    inPAClone.remove(randP2); // remove it

    // //println("point2" + point2);
    
    if (abs(point2.getX() - point1.getX()) < 100){
    
    // then we check the distance for each point to this line
    for(int j=0;j<inPA.size()-2;j++){
      
      float m = (point2.getY() - point1.getY()) / (point2.getX() - point1.getX());
      float b = point1.getY() - m * point1.getX();      
      double distance = abs(inPAClone.get(j).getY() - m * inPAClone.get(j).getX() - b) / sqrt(1 + m * m); 
      float d = (float)distance;

      if(d < threshold){ // count inliners
        inlineCounter++;
      }  
    }
      
    }
  

    // if the count was good (higher than last line) we store the the ransac line points and the inline count value as best value

    if (inlineCounter > bestInlineCount){
      ransacLine.clear();
      ransacLine.add(point1);
      ransacLine.add(point2);
      bestInlineCount = inlineCounter;
    }

    inlineCounter = 0 ; // reset inline counter
  

    }

    // when all is done we shall return the ransac line
    
    return ransacLine;

}