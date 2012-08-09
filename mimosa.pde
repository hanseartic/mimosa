import processing.serial.*;
import JMyron.*;
import fullscreen.*;
FullScreen fs;
JMyron cam;
PImage capture;

Serial arduino;

float displayTime = 1.3;

int camWidth = 
  640;
  //720;
int camHeight = 
  480;
  //576;
  
int saveCount = 0;
int time = 0;

long lastCapture = millis();
boolean capturing = false;

FilenameFilter jpgFilter = new FilenameFilter() {
  boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".jpg");
  }
};

void setup() {
  //frameRate(1);
  smooth();
  //size(screen.width, screen.height);
  size(800, 600);

  
  cam = new JMyron();
  cam.start(camWidth, camHeight);
  cam.findGlobs(0);
  
  capture = createImage(camWidth, camHeight, RGB);
  capture.loadPixels();
  
  loadPixels();
  
  fs = new FullScreen(this);
  //fs.enter();
  textFont(loadFont("Silom-48.vlw"), 18);
  thread("prepare_capture");
  println(Serial.list());
  arduino = new Serial(this, Serial.list()[0], 9600);
}
public void stop() {
  cam.stop();
  super.stop();
  arduino.stop();
}
long lastDraw = millis();
String lastDisplayedImage = "";
File displayImage;

void draw() {
  cam.update();
  thread("capture");
  long drawTime = millis();
  if (drawTime < lastDraw) lastDraw = drawTime;
  if (drawTime < lastDraw + 1000 * displayTime) return;
  lastDraw = drawTime;
  time++;
  if (saveCount <= 0) return;
  File[] files = new File(sketchPath).listFiles(jpgFilter);
  if (files.length <= 0) return;
  int imageIterator;
  lastDisplayedImage = (null != displayImage) ? displayImage.getName() : "";
  int maxImage = files.length;
  if (imageTaken) {
    maxImage--;
    imageTaken = false;
    println("Skipping last image");
  }
  for (imageIterator = 0; imageIterator < maxImage; imageIterator++) {
    if (files[imageIterator].getName().compareTo(lastDisplayedImage) > 0) {
      lastDisplayedImage = files[imageIterator].getName();      
      break;
    }
  }
  if (files.length <= imageIterator) imageIterator = 0;
  displayImage = files[imageIterator];
  if (null != displayImage) { 
    image(loadImage(displayImage.getAbsolutePath()), 0, 0, width, height); 
    String imageCaption = "Image " + imageIterator;

    String imageTime = new java.text.SimpleDateFormat("yyyyMMdd").format(displayImage.lastModified());
    imageTime = new Date(displayImage.lastModified()).toString();
    text(imageCaption, 30, height - 38);
    text(imageTime, width - (textWidth(imageTime) + 30), height - 38);
    //text(new Date(diplayImage.lastModified()).toString(), 60, 60);
  }
  //updatePixels();

}

void prepare_capture() {
  capturing = true;
  File dir = new File(sketchPath);
  if (dir.isDirectory()) {
    String[] fileNames = dir.list(jpgFilter);
    saveCount = fileNames.length;
  }
  println(saveCount);
}
String serialIn = "";
boolean imageTaken = false;
void capture() {
  boolean releaseShutter = false;
  while(arduino.available() > 0) {
    char in = char(arduino.read());
    if (in == '\n') {
      println(serialIn);
      if (serialIn.indexOf("shutter") >= 0) {
        releaseShutter = true;
      }
      serialIn = "";
    } else {
      serialIn += in;
    }
  }
  if (! releaseShutter) return;
  println("RELEASING SHUTTER");
  arduino.write("OK\n");
    long roundTime = millis();
    if (roundTime < lastCapture) lastCapture = roundTime;
    if (roundTime < lastCapture + 3000) return;//continue;
    lastCapture = roundTime;
    cam.update();
    cam.imageCopy(capture.pixels);
    capture.updatePixels();
    imageTaken = true;
    capture.save("capture" + nf((saveCount), 5) + ".jpg");
    delay(200);
    saveCount++;
}

