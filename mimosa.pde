import JMyron.*;
import fullscreen.*;
FullScreen fs;
JMyron cam;
PImage capture;

int displayCount = 0;
int saveCount = 0;
int time = 0;

int camWidth = 640;
int camHeight = 480;

long lastCapture = 0;
boolean capturing = false;

void setup() {
  frameRate(1);
  smooth();
  //size(screen.width, screen.height);
  size(800, 600);
  if (frame != null) {
    frame.setResizable(true);
  }
  
  cam = new JMyron();
  cam.start(camWidth, camHeight);
  cam.findGlobs(0);
  
  capture = createImage(camWidth, camHeight, RGB);
  capture.loadPixels();
  
  loadPixels();
  
  fs = new FullScreen(this);
  //fs.enter();
  textFont(loadFont("Silom-48.vlw"), 18);
  thread("capture");
}
boolean sketchFullScreen() {
  return true;
}
public void stop() {
  cam.stop();
  super.stop();
}
void draw() {
  
  if (time%2 == 0) {
    //
      //get("capture" + iCount + ".jpg");
      displayCount++;
    //}
  } else return;
  time++;
  if (saveCount <= 0) return;
  if (displayCount >= saveCount) displayCount = 0;
  File imageFile = new File ("capture" + nf(displayCount, 4)+ ".jpg");
  if (null != imageFile) 
    println(imageFile.getAbsolutePath());
  image(loadImage("capture" + nf(displayCount, 4)+ ".jpg"), 0, 0, width, height); 
  String imageCaption = "Image " + displayCount;

  String imageTime = new java.text.SimpleDateFormat("yyyyMMdd").format(imageFile.lastModified());
  //imageTime = new Date(imageFile.lastModified()).toString();
  text(imageCaption, 30, height - 38);
  text(imageTime, width - (textWidth(imageTime) + 30), height - 38);
}

void capture() {
  capturing = true;
  File dir = new File(sketchPath);
  if (dir.isDirectory()) {
    String[] fileNames = dir.list();
    for (int i = 0; i < fileNames.length; i++) {
      if (fileNames[i].endsWith(".jpg")) {
        saveCount++;
      }
    }
    println(fileNames);
  }
  println(saveCount);
  while(capturing && true) {
    long roundTime = millis();
    if (roundTime < lastCapture) lastCapture = roundTime;
    if (roundTime < lastCapture + 5000) continue;
    lastCapture = roundTime;
    cam.update();
    cam.imageCopy(capture.pixels);
    capture.save("capture" + nf((saveCount++), 4) + ".jpg");
  }
}
