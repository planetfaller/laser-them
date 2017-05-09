int[] DBSCAN(ArrayList<Point> inPA){
  if (clusterCount > 300){clusterCount=0;}
  int C=clusterCount; // TEST WE REMEMBER CLUSTERCOUNT
  int n = inPA.size(); // number of points
  
  boolean[] visited = new boolean[n];
  boolean[] isNoise = new boolean[n];
  
  int[] IDX = new int[n]; // index to keep track of clusters
  
  
  float[][] d = new float[n][n]; 
  IntList neighbors = new IntList();
  IntList neighbors2 = new IntList();
  
  
  
  // calculate the distance from every point in set to every other point in the set.
  for(int i=0; i<n; i++){
    for(int j=0; j<n; j++){
      d[i][j] = dist(inPA.get(i).getX(), inPA.get(i).getY(), inPA.get(j).getX(),inPA.get(j).getY());
    }
  }
  
 // go through all points in set
  for(int i=0; i < n; i++){
    if(!visited[i]){ // if not visited
      visited[i] = true; // set as visited
        neighbors = regionQuery(i,d,inPA); // collect which points are close enough
      if(neighbors.size()<minPts){ // check for min points conditions
        isNoise[i] = true; // mark as noise if true
       }
    else{
      C++; // it has a minimum amount of neighbors, and is a core point, we add a cluster
      clusterCount++;
      IDX = expandCluster(IDX,i, neighbors,C, visited, d,inPA); // call to expander function, it gets the neighbors, visited points and distance
    }
    }
   }
   
   // set clusterID for points in point cloud
   for (int i=0; i<n;i++){
     inPA.get(i).setcID(IDX[i]);
     inPA.get(i).setColor(colorList[IDX[i]]);
   }
   return IDX;
}

int[] expandCluster(int[] IDX,int i, IntList neighbors, int C, boolean[] visited, float[][] d, ArrayList<Point> inPA) {
  IDX[i] = C;
  int k = 0;
  int j;
  IntList neighbors2 = new IntList();
  
  while (true){
    j = neighbors.get(k);
    if (!visited[j]){
      visited[j] = true;
      neighbors2 = regionQuery(j,d,inPA);
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

  
IntList regionQuery(int row,float[][]d, ArrayList<Point> inPA){
  IntList neighbors = new IntList(); // we create a list to mark which points that are dense enough
  for(int i=0; i<inPA.size(); i++){
    if(d[row][i]<=eps){
      neighbors.append(i); // if close enough we add it
    }    
   }
  return neighbors; // return the intlist with neighbors
}