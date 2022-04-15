import com.phidget22.*;


VoltageRatioInput heartSensor;
Scrollbar scaleBar;

PFont font;
PFont portsFont;

//Holds heartbeat data
float [] pulses;      
float [] scaledPulses;   

float zoom;
color eggshell = color(255, 253, 248);

//Sizing of windows
int PulseWindowWidth = 490;
int PulseWindowHeight = 512;
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;

void setup() {
  size(700, 600);
  frameRate(100);
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);

  //Create scroll bar for zooming
  scaleBar = new Scrollbar (400, 575, 180, 12, 0.0, 1.0);
  
  pulses = new float[PulseWindowWidth];
  scaledPulses = new float[PulseWindowWidth];
  
  //Default zoom
  zoom = 0.75;                               

  //Drawing
  resetDataTraces();
  background(0);
  drawDataWindows();
  drawHeart();
  fill(eggshell);

  //Phidgets initialize 
  try {
    //Create
    heartSensor = new VoltageRatioInput();
    //Address
    heartSensor.setHubPort(0);
    heartSensor.setIsHubPortDevice(true);
    //Open
    heartSensor.open(1000);
    //Set data interval to minimum | This will increase the data rate from the sensor, and make your graph more responsive
    heartSensor.setDataInterval(heartSensor.getMinDataInterval());
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

void drawDataWindows() {
  noStroke();
  fill(eggshell);
  rect(255, height/2, PulseWindowWidth, PulseWindowHeight);
  rect(600, 385, BPMWindowWidth, BPMWindowHeight);  
}

void drawHeart() {
  fill(250, 0, 0);
  stroke(250, 0, 0);
  smooth();
  bezier(width-100, 50, width-20, -20, width, 140, width-100, 150);
  bezier(width-100, 50, width-190, -20, width-200, 140, width-100, 150);
  strokeWeight(1);
}

void drawPulseWaveform() {
  float pulseVal = 0;
  try {
    pulseVal = (float)heartSensor.getVoltageRatio();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  
  pulses[pulses.length-1] = ((pulseVal - 0.5)* 512);   //pulseVal is between 0 and 1. Center and scale up to fit window.
  zoom = scaleBar.getPos();  
  for (int i = 0; i < pulses.length-1; i++) {
      pulses[i] = pulses[i+1];                         // shifting all raw datapoints one pixel left
      scaledPulses[i] = pulses[i] * -zoom + height/2;  // adjust the raw data to the selected scale
  }
  stroke(250, 0, 0);                               
  noFill();
  beginShape();                                  
  for (int x = 1; x < scaledPulses.length-1; x++) {
    vertex(x+10, scaledPulses[x]);                    //draw a line connecting the data points
  }
  endShape();
}

void draw() {
  background(0);
  noStroke();
  drawDataWindows();
  drawPulseWaveform();
  drawHeart();
  
  fill(eggshell);
  text("Pulse Sensor Amped Visualizer - Phidgets", 245, 30);
  text("IBI",600,585); // TODO for next project
  text("BPM",600,200); // TODO for next project
  text("Pulse Window Scale " + nf(zoom, 1, 2), 150, 585);

  //Manage scroll bar
  scaleBar.update (mouseX, mouseY);
  scaleBar.display();
}

void resetDataTraces() {
  for (int i=0; i<pulses.length; i++) {
    pulses[i] = height/2;
  }
}
