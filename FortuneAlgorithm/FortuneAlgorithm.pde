ArrayList<PVector> generateRandomPoints(int n){
  ArrayList<PVector> points = new ArrayList<PVector>();
  float factor = 0.1; // border in percentage
  for(int i=0; i<n; i++){
    float x = random(factor*width,  (1 - factor)*width);
    float y = random(factor*height, (1 - factor)*height);
    points.add(new PVector(x, y));
  }
  return points;
}

Voronoi voronoi;
boolean animate = true;
// Number of random points
int n = 80;
// Number of frames to save after algorithm has finished
int lastFrameCount = 10;
// Check if frames are saved
boolean saveFrames = false;


void setup(){
  size(600, 600);
  stroke(0);
  frameRate(60);
  background(0);
  
  ArrayList<PVector> points = generateRandomPoints(n);
  voronoi = new Voronoi(points, width, height);
}

void draw(){
  if(animate){
    background(0);
    if(!voronoi.done){
      voronoi.update();
    }else{
      lastFrameCount--;
    }
    voronoi.draw(false);
    if(saveFrames && lastFrameCount > 0){
      saveFrame("frames/#####.png");
    }
  }
}

void keyPressed(){
  if(!saveFrames){
    if(key == ' '){
      // Pause animation
      animate = !animate;
    }else{
      // Restart with new generated points
      background(0);
      ArrayList<PVector> points = generateRandomPoints(n);
      voronoi = new Voronoi(points, width, height);
    }
  }
}