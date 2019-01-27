// Code by Max Rheiner
// Updated and reworked by Martijn de Heer on January 2019

import SimpleOpenNI.*;
import peasy.*;

PeasyCam peasy;
SimpleOpenNI kinect;

float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);

void setup() {
  size(1024, 768, P3D);
  
  peasy = new PeasyCam(this, 1000);

  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false) {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // disable mirror
  kinect.setMirror(false);

  // enable depthMap generation 
  kinect.enableDepth();

  perspective(radians(45), float(width)/float(height), 10,150000);
}

void draw() {
  kinect.update();
  background(0);

  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  int[]   depthMap = kinect.depthMap();
  int     steps   = 2;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;
 
  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  stroke(255);
  strokeWeight(2);

  PVector[] realWorldMap = kinect.depthMapRealWorld();
  
  // draw pointcloud
  for(int y=0;y < kinect.depthHeight();y+=steps) {
    for(int x=0;x < kinect.depthWidth();x+=steps) {
      index = x + y * kinect.depthWidth();
      if(depthMap[index] > 0) { 
        realWorldPoint = realWorldMap[index];
        point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
      }
    }
  } 

  // draw the kinect cam
  kinect.drawCamFrustum();
}


void keyPressed() {
  switch(key) {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  }
}
