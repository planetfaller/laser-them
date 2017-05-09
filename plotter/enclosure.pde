void enclosure(ArrayList<Point> inPA){
int n = inPA.size();
for(int i=1;i<n-2; i++){
  line(inPA.get(i).getX(),inPA.get(i).getY(),inPA.get(i+1).getX(),inPA.get(i+1).getY());
  }
}


/**
enclose=createShape();
enclose.beginShape();
enclose.noFill();
enclose.setStroke(#FFFFFF);
for(int i=0;i<n; i++){
  enclose.vertex(inPA.get(i).getX(),inPA.get(i).getY());
}
enclose.endShape();
**/