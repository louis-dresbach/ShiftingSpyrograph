import controlP5.*;

// SETTINGS
// DISC SETTINGS
disc[]  discs = { new disc(500, 0), new disc(200, 100), new disc(100, 200), new disc(50, -300), new disc(25, 400)};
int     discOpacity = 0;
color   discColor = color(0);
boolean drawCircle = false;
int     circleThickness = 3;

//DOT SETTINGS
float   dotDistance = 1;           // distance from center of disc to dot
int     dotSize = 20;
int     dotOpacity = 0;

// TRAIL SETTINGS
int     trailLength = 600; // Length of the "trail"
boolean fade = true; // Whether the end of the trail will fade away


boolean rainbow = false;
float   rFreq = .05;
float   rDist = 1.5;

color   trailColor  = color(240, 240, 0); // Color of the trial if rainbow is false

//MISC
boolean drawGUI = true;
color   background = color(30);
boolean DEBUG = false;
// END OF SETTINGS





































// Parameters

//

ControlP5 cp5;
PVector center;
boolean isRunning = true;
int framesRun = 0;
boolean isInit = false;


void setup() {
  fullScreen();
  //size(1280, 720);
  frameRate(120);

  center = new PVector(width/2, height/2);
  
  if(drawGUI) {
    cp5 = new ControlP5(this);
    cp5.addButton("start")
       .setValue(0)
       .setPosition(100, 100)
       .setSize(90, 19);
    cp5.addButton("stop")
       .setValue(0)
       .setPosition(210, 100)
       .setSize(90, 19);
    cp5.addButton("addDisc")
       .setPosition(100, 130)
       .setSize(90, 19);
    cp5.addButton("removeDisc")
       .setValue(0)
       .setPosition(210, 130)
       .setSize(90, 19);
       
    
    Group gen = cp5.addGroup("generalSettings")
       .setPosition(100, 200)
       .setBackgroundColor(color(255, 50))
       .setSize(200, 300)
       .disableCollapse();
       
    cp5.addToggle("rainbow")
       .setGroup(gen)
       .setPosition(10, 10)
       .setSize(19, 19);
    cp5.addToggle("drawCircle")
       .setValue(drawCircle)
       .setGroup(gen)
       .setPosition(60, 10)
       .setSize(19, 19);
    cp5.addToggle("fade")
       .setGroup(gen)
       .setPosition(110, 10)
       .setSize(19, 19);
       
    cp5.addSlider("trailLength")
       .setPosition(10, 30)
       .setRange(1, 2000)
       .setSize(120, 19)
       .setGroup(gen);
     
    cp5.addColorWheel("trailColor")
       .setGroup(gen)
       .setPosition(0, 80);
    
    cp5.addSlider("dotDistance")
       .setPosition(10, 300)
       .setRange(0, 3)
       .setSize(120, 19)
       .setGroup(gen);
    
    for (int i=0; i<discs.length; i++) {
      createDiscSettings(i);
    }
        
    cp5.addFrameRate().setInterval(10).setPosition(20,height - 30);
  }
  else {
    noCursor(); 
  }
  
  isRunning = true;
  isInit = true;
}

void draw() {
  background(background);
  
  if(isRunning) {
    for (int i=0; i<discs.length; i++) {
      log("Updating disc with index "+i);
      if (i==0)
        discs[i].update();
      else
        discs[i].update(discs[i-1]);
    }
    discs[discs.length-1].display();
    framesRun++;
  }
  
  // Show "frame" count
  if (drawGUI) {
    fill(255, 100, 100, 200);
    textSize(18);
    text("frame: " + framesRun + " | " + str(discs.length) + " discs" , 100, 80);
  }
}

public void start() {
 isRunning = true; 
 framesRun = 0;
 for (int i=0; i<discs.length; i++) {
   discs[i].reset();
 }
}

public void stop() {
 isRunning = false;
}


void controlEvent(ControlEvent theEvent) {
  if(isInit) {
    isInit = false;
    String name = theEvent.getController().getName();
    println("Got a control event from controller "+name);
    if(name.startsWith("discRadius")) {
      int index = int(name.substring(10));
      
      int rounded = round(theEvent.getValue() / 10) * 10;
      discs[index].radius = rounded;
      ((Slider)theEvent.getController()).setValue(rounded);
      
      println("Set new radius for disc"+index+" to "+str(rounded));
    }
    else if(name.startsWith("discSpeed")) {
      int index = int(name.substring(9));
      
      int rounded = round(theEvent.getValue() / 10) * 10;
      discs[index].speed = rounded;
      ((Slider)theEvent.getController()).setValue(rounded);
      
      println("Set new speed for disc"+index+" to "+str(theEvent.getValue()));
    }
    isInit = true;
  }
}

public void addDisc() {
  int index = discs.length;
  discs = (disc[])expand(discs, index+1);
  discs[index] = new disc(100, 100);
  createDiscSettings(index);
}

public void createDiscSettings(int index) {
  isInit = false;
  Group g = cp5.addGroup("discGroup"+index)
     .registerProperty(str(index))
     .setPosition(100, 550 + 120*index)
     .setBackgroundHeight(100)
     .setBackgroundColor(color(255, 50))
     .setSize(200, 100)
     .disableCollapse();
  
  cp5.addSlider("discRadius"+index)
     .registerProperty(str(index))
     .setPosition(10, 10)
     .setRange(20, (height-20)/2)
     .setSize(120, 19)
     .setGroup("discGroup"+index)
     .setDecimalPrecision(0)
     .setValue(discs[index].radius);
  cp5.addSlider("discSpeed"+index)
     .registerProperty(str(index))
     .setPosition(10, 40)
     .setRange(-5*frameRate, 5*frameRate)
     .setGroup("discGroup"+index)
     .setSize(120, 19)
     .setValue(discs[index].speed);
  cp5.addSlider("discAngle"+index)
     .registerProperty(str(index))
     .setPosition(10, 70)
     .setRange(0, 360)
     .setGroup("discGroup"+index)
     .setSize(120, 19)
     .setValue(discs[index].phi);
  isInit = true;
}

public void removeDisc() {
  if(discs.length > 0 && isInit) {
    isInit = false;
    int index = discs.length-1;
    cp5.remove("discGroup"+index);
    discs = (disc[])shorten(discs);
    isInit = true;
  }
}

class disc {
  private PVector[] drawn;
  private color[] colors;
  public PVector circleLocation = new PVector(0, 0);
  public PVector dotLocation = new PVector(0, 0);
  public float phi = 0;
  private float alpha = 0;
  private float omega;
  
  
  public float speed;
  public float radius; // Radius

  public disc(float r, float spd) {
    this.radius = r;
    this.speed = spd;

    drawn = new PVector[trailLength];
    colors = new color[trailLength];
  }
  public void update(disc... prev) {
    circleLocation = center.copy();
    omega = 0;

    if (prev.length == 1) {
      log("Previous disc found");
      circleLocation.x = prev[0].circleLocation.x + (prev[0].radius - this.radius - circleThickness) * sin(radians(phi));
      circleLocation.y = prev[0].circleLocation.y + (prev[0].radius - this.radius - circleThickness) * cos(radians(phi));
      omega = prev[0].radius/this.radius * speed;
    }

    dotLocation.x = circleLocation.x + ((this.radius * dotDistance) - (dotSize/2)) * sin(radians(alpha));
    dotLocation.y = circleLocation.y + ((this.radius * dotDistance) - (dotSize/2)) * cos(radians(alpha));

    phi += speed / frameRate;
    alpha += omega / frameRate;

    if (drawCircle) {
      strokeWeight(circleThickness);
      stroke(color(255, 255, 255), 255);
      fill(discColor, discOpacity);
      circle(circleLocation.x, circleLocation.y, 2*radius);
    }
  }
  
  public void reset() { 
    drawn = new PVector[trailLength];
    colors = new color[trailLength];
    phi = 0;
    alpha = 0;
  }

  public void display() {
    if (drawn.length != trailLength) {
      drawn = new PVector[trailLength];
      colors = new color[trailLength];
    }

    drawn[0] = new PVector(dotLocation.x, dotLocation.y);
    float red = sin(framesRun*rFreq)*127 + 128;
    float grn = sin(framesRun*rFreq+rDist)*127 + 128;
    float blu = sin(framesRun*rFreq+2*rDist)*127 + 128;
    colors[0] = color(int(red), int(grn), int(blu));
    for (int i=drawn.length-1; i>0; i--) {
      if (i>=drawn.length)
        break;
      drawn[i] = drawn[i-1];
      colors[i] = colors[i-1];
    }

    strokeJoin(ROUND);
    strokeWeight(dotSize);
    for (int i = 0; i < drawn.length-1; i++) {
      if (drawn[i] != null && drawn[i+1] != null) {
        float alp;
        if (fade)
          alp = 255 * (1 - float(i) / drawn.length);
        else
          alp = 255;
        if (fade) {
          strokeWeight(dotSize * (1 - float(i) / drawn.length));
        }
        if (rainbow) {
          stroke(colors[i], alp);
        } else {
          stroke(trailColor, alp);
        }
        line(drawn[i].x, drawn[i].y, drawn[i+1].x, drawn[i+1].y);
      }
    }


    fill(255, 255, 255, dotOpacity);
    strokeWeight(2);
    if (drawCircle)
      circle(dotLocation.x, dotLocation.y, dotSize);
  }
}

void log(String text) {
  if (DEBUG) {
    println(text);
  }
}
