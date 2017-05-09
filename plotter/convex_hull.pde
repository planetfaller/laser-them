

void convex_Hull(ArrayList<Point> inPA){
ArrayList<Point> hull;
Point h1;
Point h2;
Point h3;
hull = new ArrayList();
h1 = new Point(0,0);
h2 = new Point(0,0);
h3 = new Point(0,0);


for (int i = 0; i < inPA.size(); i++) {
println(inPA.get(i).getX());
}

java.util.Collections.sort(inPA); // sort by x ascending
hull.add(inPA.get(0));
hull.add(inPA.get(1));

drawHull(inPA);

 int currentPoint = 2;
 int direction = 1;
  // add the next point
  hull.add(inPA.get(currentPoint));


  // look at the turn direction in the last three points
  // (we have to work with copies of the points because Java)
  h1 = hull.get(hull.size() - 3);
  h2 = hull.get(hull.size() - 2);
  h3 = hull.get(hull.size() - 1);

  // while there are more than two points in the hull
  // and the last three points do not make a right turn
  while (!isRightTurn (h1, h2, h3) && hull.size() > 2) {
    // remove the middle of the last three points
    hull.remove(hull.size() - 2);
    
    // refresh our copies because Java
    if (hull.size() >= 3) {
      h1 = hull.get(hull.size() - 3);
    }
    h2 = hull.get(hull.size() - 2);
    h3 = hull.get(hull.size() - 1);
  } 

  // going through left-to-right calculates the top hull
  // when we get to the end, we reverse direction
  // and go back again right-to-left to calculate the bottom hull
  if (currentPoint == inPA.size() -1 || currentPoint == 0) {
    direction = direction * -1;
  }

  currentPoint+= direction;

}

// use the cross product to determin if we have a right turn
boolean isRightTurn(Point a, Point b, Point c) {
  return ((b.getX() - a.getX())*(c.getY() - a.getY()) - (b.getY() - a.getY())*(c.getX() - a.getX())) >= 0;
}

void drawHull(ArrayList<Point> inPA) {
  stroke(255, 0, 0);
  for (int i = 1; i < inPA.size(); i++) {
    line(inPA.get(i).getX(), inPA.get(i).getY(), inPA.get(i-1).getX(), inPA.get(i-1).getY());
  }
}

PVector copyOf(PVector p){
  return new PVector(p.x, p.y);
}