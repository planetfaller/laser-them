/**
 Point class for storing 2 dimensional points as objects
 **/
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
  /**
    Get Y coordinate
    
    @return {float} x coordinate
  */
  float getX() {
    return X;
  }
  /**
    Get Y coordinate
    
    @return {float} y coordinate
  */
  float getY() {
    return Y;
  }
  /**
    Get relative time of birth
    
    @return {float} relative time
  */
  float getTime() {
    return timeDiff;
  }
  /**
    Get point ID
    
    @return {int} ID
  */
  int getId() {
    return id;
  }
  /**
    Get point color
    
    @return {color} color of point
  */
  color getColor() {
    return pointColor;
  }
  /**
    Get cluster ID
    
    @return {int} cluster ID
  */
  int getClusterID() {
    return clusterID;
  }
  /**
    Set cluster ID
    
    @param {int} cluster ID
    @return void
  */
  void setcID(int incID) {
    clusterID = incID;
  }
  /**
    Set point color
    
    @param {color} point color
    @return void
  */
  void setColor(color inColor) {
    pointColor = inColor;
  }
  /**
    Set sorting mode
    
    @param {int} sm sorting mode selector
    @return void
  */
  void setSortMode(int sm) {
    sortMode = sm;
  }

  /**
      Comparator function
  */
  @Override int compareTo(Point p0) {
    if (xory==0)
    {
      return (int)Math.signum(X-p0.getX()); // X decending
    } else if (xory==1)
    {
      return (int)Math.signum(Y-p0.getY()); // Y decending
    } else 
    {
      return (int)Math.signum(clusterID-p0.getClusterID()); // Y decending
    }
  }
}