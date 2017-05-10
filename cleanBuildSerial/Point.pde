class Point implements Comparable<Point>
{
  float X;
  float Y;
  float timeDiff;
  color pointColor;
  int id;
  int clusterID;
  int sortMode;

  // Constructor
  Point(float inX, float inY, float inTimeDiff, color inPointColor, int inId) {
    X = inX;
    Y = inY;
    timeDiff = inTimeDiff;
    pointColor = inPointColor;
    id = inId;
    clusterID = 0; // cluster
    sortMode = 1;
  }

  Point(float inX, float inY) {
    X = inX;
    Y = inY;
    timeDiff = 0;
    pointColor = 0;
    id = 0;
    clusterID = 0; // cluster
    sortMode = 0;
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
  
  void setSortMode(int sm){
    sortMode = sm;
  }
  
  @ Override int compareTo(Point p0){
    if (xory==0)
    {
      return (int)Math.signum(X-p0.getX()); // X decending
    }
    else
    {
      return (int)Math.signum(Y-p0.getY()); // Y decending
    }
  }
  
  
  
  
}