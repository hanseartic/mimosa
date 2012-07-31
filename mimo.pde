import processing.video.*;
import fullscreen.*;
FullScreen fs;
Capture cam;
PImage capture;
int iCount = 0;
int oCount = 0;
int time = 0;

void setup() {
  frameRate(1);
  smooth();
  //size(screen.width, screen.height);
  size(800, 600);
  if (frame != null) {
    frame.setResizable(true);
  }
  println(Capture.list());
  //cam = new Capture(this, width, height, Capture.list()[2]);
  cam = new Capture(this, 2848, 2136, Capture.list()[2]);
  fs = new FullScreen(this);
  //fs.enter();
}
boolean sketchFullScreen() {
  return true;
}
void draw() {
  time++;
  if (time%5 == 0) {
    if (cam.available()) {
      cam.read();      
      capture = cam.get(0, 0, cam.width, cam.height);
      capture.save("capture" + iCount + ".jpg");
      //get("capture" + iCount + ".jpg");
      iCount++;
    }
  }
  if (iCount <= 0) return;
  if (oCount >= iCount) oCount = 0;
  image(loadImage("capture" + (oCount++) + ".jpg"), 0, 0);
  
}
