/**
  Calculates each points cluster identity based on DBSCAN algorithm and global variables minPts and eps
  Code based on : https://en.wikipedia.org/wiki/DBSCAN and http://yarpiz.com/255/ypml110-dbscan-clustering

  @param {ArrayList<Point>} inPA array list of 2 dimensional point objects to run DBSCAN on
  @return {IntList} IDX list of each points cluster identity
**/
int[] DBSCAN(ArrayList<Point> inPA) {
  clusterCount = 0;
  int C=0;
  int n = inPA.size(); // number of points

  boolean[] visited = new boolean[n];
  boolean[] isNoise = new boolean[n];

  int[] IDX = new int[n]; // index to keep track of clusters

  float[][] d = new float[n][n]; 
  IntList neighbors = new IntList();
  // IntList neighbors2 = new IntList();

  // calculate the distance from every point in set to every other point in the set.
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      d[i][j] = dist(inPA.get(i).getX(), inPA.get(i).getY(), inPA.get(j).getX(), inPA.get(j).getY());
    }
  }

  // go through all points in set
  for (int i=0; i < n; i++) {
    if (!visited[i]) { // if not visited
      visited[i] = true; // set as visited
      neighbors = regionQuery(i, d, inPA); // collect which points are close enough
      if (neighbors.size()<minPts) { // check for min points conditions
        isNoise[i] = true; // mark as noise if true
      } else {
        C++; // it has a minimum amount of neighbors, and is a core point, we add a cluster
        clusterCount++;
        IDX = expandCluster(IDX, i, neighbors, C, visited, d, inPA); // call to expander function, it gets the neighbors, visited points and distance
      }
    }
  }

  // set clusterID for points in point cloud
  for (int i=0; i<n; i++) {
    inPA.get(i).setcID(IDX[i]);
    inPA.get(i).setColor(colorList[IDX[i]]);
  }
  return IDX;
}

/**
  Expands cluster
  
  @param {IntList} IDX current cluster list
  @param {int} i iterator
  @param {IntList} neighbors current neighbors
  @param {int} C current number of clusters
  @param {boolean[]} visited current list of visited 
  @param {float[][]} d matrix with point distances
  @param {ArrayList<Point>} inPA aray list with points 
  
  @return {IntList} IDX intlist of current points cluster identity
**/
int[] expandCluster(int[] IDX, int i, IntList neighbors, int C, boolean[] visited, float[][] d, ArrayList<Point> inPA) {
  IDX[i] = C;
  int k = 0;
  int j;
  IntList neighbors2 = new IntList();

  while (true) {
    j = neighbors.get(k);
    if (!visited[j]) {
      visited[j] = true;
      neighbors2 = regionQuery(j, d, inPA);
      if (neighbors2.size() >= minPts) {
        for (int m=0; m < neighbors2.size(); m++) {
          neighbors.append(neighbors2.get(m));
        }
      }
    } 
    if (IDX[j]==0) {
      IDX[j]=C;
    }
    k++;
    if (k> neighbors.size()-1) {
      break;
    }
  } 
  return IDX;
}

/**
  Check for points in range if to be included in cluster
  
  @param {int} row which row to check against
  @param {float[][]} d matrix with point distances
  @param {ArrayList<Point>} inPA aray list with points 
  
  @return {IntList} neighbors intlist with neighbors
*/
IntList regionQuery(int row, float[][]d, ArrayList<Point> inPA) {
  IntList neighbors = new IntList(); // we create a list to mark which points that are dense enough
  for (int i=0; i<inPA.size(); i++) {
    if (d[row][i]<=eps) {
      neighbors.append(i); // if close enough we add it
    }
  }
  return neighbors; // return the intlist with neighbors
}