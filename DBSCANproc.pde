FloatList xList;
FloatList yList;
int eps = 100;
int minPts = 5;


void setup() {
  size(1000, 1000);
  xList = new FloatList();
  yList = new FloatList();
  for(int i=0;i<50;i++){
    xList.append(random(0,200));
    yList.append(random(0,200));
  }
  
   for(int i=0;i<50;i++){
    xList.append(random(800,1000));
    yList.append(random(800,1000));
  }

  
}

void draw() {
  background(#000000);
  stroke(#FFFFFF);
  int[] cluster = new int[100];
  cluster = DBSCAN();
  colorMode(HSB);
  for(int i=0;i<100;i++){

    fill(100, cluster[i]*20, 100);
    
    noStroke();
    rect(xList.get(i), yList.get(i),10,10);
  }
  // DBSCAN();
  println(DBSCAN());
  
  
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
  
  for(int i=0; i < n; i++){
    if(!visited[i]){
      visited[i] = true;
        neighbors = regionQuery(i,d); // collect neighborpoints
      if(neighbors.size()<minPts){
        isNoise[i] = true;
       }
    else{
      C++;
      IDX = expandCluster(IDX,i, neighbors,C, visited, d);
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
  IntList neighbors = new IntList();
  for(int i=0; i<xList.size(); i++){
    if(d[row][i]<=eps){
      neighbors.append(i);
    }    
   }
  return neighbors; // return the intlist with neighbors
}

  
  

  
    
// dist(x1, y1, x2, y2)