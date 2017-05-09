class Zone {
  float minDistAngle;
  float lastMinDistAngle;
  float minAngle;
  float maxAngle;
  float minDist = Float.MAX_VALUE;
  float lastMinDist;
  String name; 
  int pos = -1;
  boolean wasTrue = false;
  Timer timer; 

  //Constructor
  Zone(float minAngleTemp, float maxAngleTemp, String nameTemp) {
    minAngle = minAngleTemp;
    maxAngle = maxAngleTemp;
    name = nameTemp;
    timer = new Timer();
  }

  float getLowestDist() {
    if (minDist != Float.MAX_VALUE) {
      lastMinDist = minDist;
    } 
    minDist = Float.MAX_VALUE;
    for (int i=0; i<distanceList.size(); i++) {
      if (distanceList.get(i) < minDist && angleList.get(i) > minAngle && angleList.get(i) < maxAngle) {
        pos=i;
        minDist=distanceList.get(i);
      }
    }
    return lastMinDist;
  }
  boolean proximityWarning() {
    if (lastMinDist < 30)
      return true;
    else {
      return false;
    }
  }
  float getLowestAngle() {
    lastMinDistAngle = minDistAngle;
    if (pos > 0 && pos <101) {
      minDistAngle = angleList.get(pos);
    }
    return minDistAngle;
  }
  boolean collisionOrNot() {
    if (lastMinDist - minDist > 20) {
      return true;
    } 
    return false;
  }

  boolean collisionWithDelay() {
    if (collisionOrNot()) {
      wasTrue = true;
      timer.reset();
      return true;
    } else if (wasTrue) {
      if (timer.getTime() < 1000) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }
  String getName() {
    return name;
  }
  
  
  
}