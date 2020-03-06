import processing.video.*;
import gab.opencv.*;

ArrayList<String> list = new ArrayList<String>();
ArrayList<words> wordPos = new ArrayList<words>();

int speed = 5;
color colorToMatch = color(0, 0, 0);

color[] colors ={#F20C0C, #FF9100, #FFF700};

Capture webcam;
OpenCV cv;
PFont font;

void setup() {
  size(640, 480);

  font = loadFont("BradleyHandITC-48.vlw");
  textFont(font, 20);
  textAlign(CENTER, CENTER);

  String[] lines = loadStrings("to-do.txt");
  for (int i = 0; i < lines.length; i++) {
    list.add(lines[i]);
  }

  cv = new OpenCV(this, width, height);

  // start the webcam
  String[] inputs = Capture.list();
  if (inputs.length == 0) {
    println("Couldn't detect any webcams connected!");
    exit();
  } else {
    for (int i = 0; i < inputs.length; i++) {
      println("List number: " + i + "  " + inputs[i]);
    }
    webcam = new Capture(this, inputs[1]);
    webcam.start();
  }
}


void draw() {
  if (webcam.available()) {

    webcam.read();
    cv.loadImage(webcam);

    int threshold = int( map(mouseY, 0, height, 0, 255) );
    cv.threshold(threshold);
    cv.dilate();
    cv.erode();
    //image(cv.getOutput(), 0, 0);

    image(webcam, 0, 0);

    list.clear();
    String[] lines = loadStrings("to-do.txt");
    for (int i = 0; i < lines.length; i++) {
      list.add(lines[i]);
    }

    PVector first = findColor(cv.getOutput(), colorToMatch);
    if (first != null) {
      wordPos.add(new words (first.x, first.y));

      for (int i = 0; i < wordPos.size(); i++) {
        words w = wordPos.get(i);
        if (w.opacity <= 150) {
          wordPos.remove(i);
        } else {
          if (list.size() > 0) {
            w.wiggle();
          }
        }
      }
    }
  }
}

// find the first instance of a color and return the location
PVector findColor(PImage in, color c) {
  float matchR = c >> 16 & 0xFF;
  float matchG = c >> 8 & 0xFF;
  float matchB = c & 0xFF;

  in.loadPixels();
  for (int y=0; y<in.height/2; y++) {
    for (int x=0; x<in.width; x++) {

      // get rgb values for the current pixel
      color current = in.pixels[y*in.width+x];
      float r = current >> 16 & 0xFF;
      float g = current >> 8 & 0xFF;
      float b = current & 0xFF;

      if (r == matchR && g == matchG && b == matchB) {
        return new PVector(x, y);
      }
    }
  }

  return null;
}

class words {
  float x;
  float y;
  String l;
  int opacity;
  int size;
  color fill;

  words(float x_, float y_) {
    x = x_;
    y = y_;
    if (list.size() > 0) {
      l = list.get(int(random(0, list.size())));
    }
    opacity = 255;
    size = int(random(10, 30));
    fill = int(random(0, 2));
  }

  void wiggle() {
    textSize(size);
    fill(colors[fill], opacity);
    if (l != null) {
      text(l, x += random(-speed, speed), y += random(-speed, speed));
    }
    opacity--;
  }
}
