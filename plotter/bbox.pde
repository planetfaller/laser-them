void bbox(ArrayList<Point> inPA){
int n = inPA.size();
  /**
  for (int i=1;i<inPA.size();i++){
    if(inPA.get(i).getX() < minXPoint.getX()){
      minXPoint = inPA.get(i);
      l=i;
    }
  }
  **/

  rect(inPA.get(0).getX(),inPA.get(0).getY(),inPA.get(n-1).getX(),inPA.get(n-1).getY());
 
}