import oscP5.*;
import netP5.*;

OscP5 oscP5;
//New
NetAddress myRemoteLocation;
OscMessage bangMessage = new OscMessage("bang");

int numAddCircles = 3;
float averageRadius = 0;
float averageXSpeed = 0;
float averageYSpeed = 0;

Circle[] _circleArr = {};


void setup() { 
  size(500, 300); 
  background(255); 
  smooth(); 
  strokeWeight(1); 
  fill(150, 50); 
  drawCircles();
  
  oscP5 = new OscP5(this, 12000);
  //New
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);


}

void draw() {
  background(255);
  for(int i=0; i<_circleArr.length; i++){
    Circle thisCirc= _circleArr[i];
    thisCirc.updateMe();
  }
}

void mouseReleased() { 
  drawCircles();
}

void drawCircles() {
  for (int i=0; i<numAddCircles; i++) {
    Circle thisCirc = new Circle();
    thisCirc.drawMe();
    _circleArr = (Circle[])append(_circleArr,thisCirc);
  }
}

//========objects

class Circle{
  float x, y;
  float radius;
  color linecol, fillcol;
  float alph;
  float xmove, ymove;
  
  Circle(){
    x = random(width);
    y = random(height);
    radius = random(100)+10;
    linecol = color(random(255), random(255), random(255));
    fillcol = color(random(255), random(255), random(255));
    alph = random(255);
    xmove = random(averageXSpeed)-2;
    ymove = random(averageYSpeed)-2;
  }

  
  void drawMe(){
    noStroke();
    fill(fillcol, alph);
    ellipse(x,y,radius*2,radius*2);
    stroke(linecol,150);
    noFill();
    ellipse(x,y,10,10);
  }
  
  void updateMe(){
    x +=xmove;
    y +=ymove;
    if (x>(width+radius)) {x=0-radius;}
    if (x<(0-radius)) {x=width+radius;}
    if (y>(height+radius)) {y=0-radius;}
    if (y<(0-radius)){y=height+radius;}
    
    for (int i=0; i<_circleArr.length; i++){
      Circle otherCirc = _circleArr[i];
      if (otherCirc !=this){
        float dis = dist(x, y, otherCirc.x, otherCirc.y);
        float overlap = dis - radius - otherCirc.radius;
        
        if (overlap < 0){
          float midx, midy;
          midx = (x + otherCirc.x)/2;
          midy = (y + otherCirc.y)/2;
          stroke(0, 100);
          noFill();
          overlap *= -1;
          ellipse(midx, midy, overlap, overlap);
          //New
          println("bang");
         // bangMessage.add("bang");
          oscP5.send(bangMessage, myRemoteLocation);
        }
      }
    }
    
    drawMe();
  }
}

//========communication

void oscEvent(OscMessage m) {
  println(m.addrPattern());
  println(m.arguments());
  synchronized(this) {
   //--Code required if you want to report bangs from Max to Processing 
   //if(m.checkAddrPattern("bang")) {
     // for(int i =0 ; i < 2500; i++) {
       // iterate();
     // }
    }
    if(m.checkAddrPattern("/numAddCircles")) {
      numAddCircles = (m.get(0).intValue());
    }
    if(m.checkAddrPattern("/averageRadius")) {
      averageRadius = (m.get(0).floatValue());
    }
    if(m.checkAddrPattern("/averageXSpeed")) {
      averageXSpeed = (m.get(0).floatValue());
    }
    if(m.checkAddrPattern("/averageYSpeed")) {
      averageYSpeed = (m.get(0).floatValue());
    }
  }
