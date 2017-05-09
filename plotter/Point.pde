class Point implements Comparable<Point>
{
  float X;
  float Y;
  float timeDiff;
  color pointColor;
  int id;
  int clusterID;

  // Constructor
  Point(float inX, float inY, float inTimeDiff, color inPointColor, int inId) {
    X = inX;
    Y = inY;
    timeDiff = inTimeDiff;
    pointColor = inPointColor;
    id = inId;
    clusterID = 0; // cluster
  }

  Point(float inX, float inY) {
    X = inX;
    Y = inY;
    timeDiff = 0;
    pointColor = 0;
    id = 0;
    clusterID = 0; // cluster
  }

  float getX() {
    return X;
  }

  float getY() {
    return Y;
  }

  int getId() {
    return id;
  }
  color getColor(){
  return pointColor;
  }
  int getClusterID(){
  return clusterID;
  }
  void setcID(int incID){
    clusterID = incID;
  }
  void setColor(color inColor){
    pointColor = inColor;
  }
  
  @ Override int compareTo(Point p0){
    return (int)Math.signum(X-p0.getX()); // decending
  }
  
  
  
  
}