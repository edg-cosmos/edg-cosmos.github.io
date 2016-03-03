import processing.video.*;
import blobscanner.*;

Capture cam;
PImage img;
Detector bd;
int threshold = 3500;
ArrayList<PVector> balloons = new ArrayList<PVector>();
float spawnRate = 1;
float speed = 50;
float easing = 0.2;

float fireE = 0.3;
float elapE = 0;
int armor = 50;
float time = 15;
boolean game = false;
int score = 0;

PVector pos = new PVector(0,0);


void setup() {
  size(1280, 480, P3D);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[3]);
    cam.start();
    img = loadImage("balloon.png");
  }      
}

void draw() {
  background(80);
  if (cam.available() == true) {
    cam.read();
  }
  if (random(1) < spawnRate/frameRate) {
    spawnBalloon();
  }

  color boundingBoxCol = color(255, 0, 0);
  color selectBoxCol = color(0, 255, 0);
  int boundingBoxThickness = 1;
  cam.loadPixels();
  bd = new Detector(this, 255);
  cam.filter(THRESHOLD);
  //bd.setThreshold(threshold);
  bd.findBlobs(cam.pixels, cam.width, cam.height);
  bd.loadBlobsFeatures(); 
  bd.weightBlobs(true);
  image(cam, 0, 0);
  if(bd.getBlobsNumber() > 0) {
    bd.drawSelectBox(threshold, selectBoxCol, boundingBoxThickness + 1);
  }
  float targetX = pos.x;
  float targetY = pos.y;
  bd.findCentroids();
  PVector[] cornorA = bd.getA();
  PVector[] cornorB = bd.getB();
  float wi = 200;
  for(int i = 0; i < bd.getBlobsNumber(); i++) {
    if(bd.getBlobWeight(i) > threshold) {
      stroke(0, 255, 0);
      strokeWeight(5);
        
      //...computes and prints the centroid coordinates x y to the console...
      println("BLOB " + (i+1) + " CENTROID X COORDINATE IS " + bd.getCentroidX(i));
      println("BLOB " + (i+1) + " CENTROID Y COORDINATE IS " + bd.getCentroidY(i));
      targetX = 640 - bd.getCentroidX(i);
      targetY = bd.getCentroidY(i);
      wi = cornorB[i].x - cornorA[i].x;
      print (wi);
      fill(255, 0, 0);
      text("x-> " + bd.getCentroidX(i) + "\n" + "y-> " + bd.getCentroidY(i), bd.getCentroidX(i), bd.getCentroidY(i)-7);
    }
  }
  
  if(wi < 160) {
    fire();
  }
  if (wi > 300 && !game) {
    startgame();
  }
  pos.x += (targetX - pos.x) * easing;
  pos.y += (targetY - pos.y) * easing;
  
  pushMatrix();
  translate(640,0);
  ellipse(pos.x, pos.y, 10, 10);
  
  for (PVector a : balloons) {
    image(img, a.x - 50, a.y - 50, img.width/8, img.height/8);
  }
  for (int i = 0; i < balloons.size(); i++) {
    balloons.get(i).y -= speed/frameRate;
    if (balloons.get(i).y < -100) {
      balloons.remove(i);
      i -= 1;
    }
  }
  textSize(10);
  text("armor: " + armor, 10, 20);
  text("time left: " + (int)time, 10, 40);
  textSize(30);
  if (!game) {
    text("Game Over" ,400, 450);
  }

  text("Score: " + score, 20, 450);

  popMatrix();
  elapE += 1/frameRate;
  if(game) {
    time -= 1/frameRate;
    if (time < 0) {
      endgame();
    }
  }
  

}

void keyPressed() {
  if (key == 'j') {
    threshold -= 50;
  }
  else if (key == 'k') {
    threshold += 50;
  }
  println(threshold);
}

void spawnBalloon() {
   balloons.add(new PVector(random(50, 590), 480)); 
}

void fire() {
  if (elapE < fireE) {
    return;
  }
  if (game) {
    armor -= 1;
    if (armor == 0) {
      endgame();
    }
  }
  for (int i = 0; i < balloons.size(); i++) {
    balloons.get(i).y -= speed/frameRate;
    if (dist(balloons.get(i).x, balloons.get(i).y, pos.x, pos.y) < 40) {
      balloons.remove(i);
      if (game) {
        score += 1;
      }
      i -= 1;
    }
  }
  elapE = 0;
}

void startgame() {
  game = true;
  score = 0;
}

void endgame() {
  game = false;
  armor = 50;
  time = 15;
}