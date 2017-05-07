FloatList xList;
FloatList yList;
int eps = 70; // epsilon, condition distance p2p to form cluster
int minPts = 3; // minimum points to form a closter > 3
  
color[] colorList = new color[100];

void setup() {
  size(1000, 1000);
  xList = new FloatList();
  yList = new FloatList();
  
  

  
  
  for (int i=0;i<100; i++){
    colorList[i] = color(random(0,255), random(0,255), random(0,255));
  // println(colorList[i]);
  }
}

void draw() {
  background(#000000);
    for(int i=0;i<50;i++){
    xList.append(random(0,200));
    yList.append(random(0,200));
  }
  
   for(int i=0;i<50;i++){
    xList.append(random(800,1000));
    yList.append(random(800,1000));
  }
  
     for(int i=0;i<50;i++){
    xList.append(random(300,400));
    yList.append(random(300,400));
  }
  
       for(int i=0;i<50;i++){
    xList.append(random(700,800));
    yList.append(random(200,600));
  }
  
 for(int i=0;i<10;i++){
    xList.append(random(0,1000));
    yList.append(random(0,1000));
  }
  
  int[] cluster = new int[100];
  cluster = DBSCAN();
  for(int i=0;i<210;i++){
    
    fill(colorList[cluster[i]]);
    noStroke();
    if (cluster[i]!=0){
    rect(xList.get(i), yList.get(i),10,10);
    }
    else{
    ellipse(xList.get(i), yList.get(i),20,20);
    }
  }
  // DBSCAN();
  println(DBSCAN());
  xList.clear();
  yList.clear();
  // delay(500);
}

int[] DBSCAN(){
  int C=0;
  int n = xList.size(); // number of points
  
  boolean[] visited = new boolean[n];
  boolean[] isNoise = new boolean[n];
  
  int[] IDX = new int[n]; // index to keep track of clusters
  
  
  float[][] d = new float[xList.size()][xList.size()]; 
  IntList neighbors = new IntList();
  IntList neighbors2 = new IntList();
  
  
  
  // calculate the distance from every point in set to every other point in the set.
  for(int i=0; i<n; i++){
    for(int j=0; j<n; j++){
      d[i][j] = dist(xList.get(i), yList.get(i), xList.get(j),yList.get(j));
    }
  }
  
 // go through all points in set
  for(int i=0; i < n; i++){
    if(!visited[i]){ // if not visited
      visited[i] = true; // set as visited
        neighbors = regionQuery(i,d); // collect which points are close enough
      if(neighbors.size()<minPts){ // check for min points conditions
        isNoise[i] = true; // mark as noise if true
       }
    else{
      C++; // it has a minimum amount of neighbors, and is a core point, we add a cluster
      IDX = expandCluster(IDX,i, neighbors,C, visited, d); // call to expander function, it gets the neighbors, visited points and distance
    }
    }
   }
   return IDX;
}

int[] expandCluster(int[] IDX,int i, IntList neighbors, int C, boolean[] visited, float[][] d) {
  IDX[i] = C;
  int k = 0;
  int j;
  IntList neighbors2 = new IntList();
  
  
  while (true){
    j = neighbors.get(k);
    if (!visited[j]){
      visited[j] = true;
      neighbors2 = regionQuery(j,d);
      if (neighbors2.size() >= minPts){
            for(int m=0; m < neighbors2.size(); m++){
              neighbors.append(neighbors2.get(m));
            }
        }
      }
    
                if (IDX[j]==0){
                IDX[j]=C;
                }
                k++;
                if(k> neighbors.size()-1){
                  break;
                }
  }
 
  return IDX;
}

  
IntList regionQuery(int row,float[][]d){
  IntList neighbors = new IntList(); // we create a list to mark which points that are dense enough
  for(int i=0; i<xList.size(); i++){
    if(d[row][i]<=eps){
      neighbors.append(i); // if close enough we add it
    }    
   }
  return neighbors; // return the intlist with neighbors
}

  
  
