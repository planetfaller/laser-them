class Point
{
  float X;
  float Y;
  float timeDiff;
  color pointColor;
  int id;

  // Constructor
  Point(float inX, float inY, float inTimeDiff, color inPointColor, int inId) {
    X = inX;
    Y = inY;
    timeDiff = inTimeDiff;
    pointColor = inPointColor;
    id = inId;
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
  
}