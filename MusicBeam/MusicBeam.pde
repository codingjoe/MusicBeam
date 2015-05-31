import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.awt.DisplayMode;

import java.util.LinkedList;

import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

String version = "1.1.2";

public Boolean debugMode = false;

Stage stage = null;

Strobe_Effect strobo;

GraphicsDevice[] gs;

ControlP5 cp5;

Minim minim;

AudioSource in;

BeatDetect bdFreq, bdSound;

PImage[] randomImg;

LinkedList<Beat> beatHistory = new LinkedList();

Effect[] effectArray;

DropdownList displays;

Toggle projectorToggle, randomToggle;
Slider randomTimeSlider, beatDelaySlider, minLevelSlider,lineSizeSlider,smoothnesSlieder;
Button nextButton;
RadioButton activeEffect, activeSetting;

FFT fft;
fftBuffer buffer;
int fftSize = 4;


float randomTimer = 0;

int randomEffect = 0;

float maxLevel = 0;
float goalMaxLevel=0;
float maxFreq=0;

int baseColor = 0;
int lastBeat = 0;
Color kickColor;
int goalBaseColor;
int colorFlow = 0;

int maxIndex = 0;
float meanMaxIndex = 0;

int mod(int a, int b){
  if(a>0)return a%b;
  a*=-1;
  return a%b;
}

void setup() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  gs = ge.getScreenDevices();


  size(415, 425);
  frame.setTitle("MusicBeam v"+version);
  frame.setIconImage( getToolkit().getImage("sketch.ico") );
  frame.setResizable(true);

  Minim minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);

  bdFreq = new BeatDetect(in.bufferSize(), in.sampleRate());
  bdSound = new BeatDetect();
  
  fft = new FFT(in.bufferSize()*fftSize, in.sampleRate());
  buffer=new fftBuffer(in.mix.size());
  kickColor = new Color();
  
  colorMode(HSB, 360, 100, 100);

  initControls();
  checkForUpdate();
}
float[] FrequencyColor;
void draw() {
  if (stage==null)
    beatDetect();
  background(25);

  noStroke();

  drawBeatBoard();
  drawFrequencies( 10, 360);
  
  kickColor.r *= 0.95;
  kickColor.g *= 0.95;
  kickColor.b *= 0.95;
  
  baseColor+=0.001;
  baseColor%=256;
  lastBeat++;
  
  if(colorFlow>0)
  {
    baseColor=(baseColor*14+goalBaseColor)/15;
    colorFlow--;
  }
  
  Color col = Wheel(int((baseColor+meanMaxIndex*8)%255));
  
  if(isHat()) {if(colorFlow==0){goalBaseColor =mod(int(baseColor+40),256);colorFlow=15;}}
  if(isKick()) {if(lastBeat>15){kickColor = Wheel(mod(int(baseColor-50),255)); lastBeat=0;}}
  
  
  // maybe not the best way. But it will result in a nice flash!
  if((col.r =col.r + kickColor.r)>255)col.r=255;
  if((col.g =col.g + kickColor.g)>255)col.g=255;
  if((col.b =col.b + kickColor.b)>255)col.b=255;
  
  float[] colors = java.awt.Color.RGBtoHSB(col.r,col.g,col.b,null);
  FrequencyColor = colors;
  FrequencyColor[0]*=360;
  FrequencyColor[1]*=100;
  FrequencyColor[2]*=100;
  
  fill(FrequencyColor[0], FrequencyColor[1], FrequencyColor[2]);
  rect(357,260,48,48);

  colors = java.awt.Color.RGBtoHSB(kickColor.r,kickColor.g,kickColor.b,null);
  fill(colors[0]*360,colors[1]*100,colors[2]*100);
  rect(357,310,48,48);
  
  if (effectArray!=null) {
    for (Effect e:effectArray)
      e.hideControls();
    if (int(activeSetting.getValue())>=0)
      effectArray[int(activeSetting.getValue())].showControls();
  }

  if (randomToggle!=null)
    if (randomToggle.getState()&&randomTimer>=randomTimeSlider.getValue()*60)
    {
      nextRandom();
    }
    else if (randomToggle.getState())
      randomTimer++;
}

void nextRandom()
{
  int k = randomEffect;
  while (randomEffect==k || !effectArray[k].randomToggle.getState ())
    k = int(random(effectArray.length));
  randomEffect = k;
  activeEffect.activate(randomEffect);
  randomTimer = 0;
}

void controlEvent(ControlEvent event)
{
  if (event.getName()=="next")
    nextRandom();
}

void drawBeatBoard()
{
  fill(200, 100, 20);
  rect(10, 70, 354, 122);
  fill(120, 100, getLevel()>minLevelSlider.getValue()&&bdFreq.isHat() ? 100 : 20);
  rect(365, 70, 40, 40);
  fill(220, 100, getLevel()>minLevelSlider.getValue()&&bdFreq.isSnare() ? 100 : 20);
  rect(365, 111, 40, 40);
  fill(320, 100, getLevel()>minLevelSlider.getValue()&&bdFreq.isKick() ? 100 : 20);
  rect(365, 152, 40, 40);
  fill(0);

  textSize(32);
  textAlign(CENTER, CENTER);
  text("H", 385, 88);
  text("S", 385, 129);
  text("K", 385, 170);
  textAlign(LEFT, BOTTOM);
  drawBeatHistory(beatHistory, 10, 170);
}

/** Draws a beat Visualisation.
 * @param LinkedList<Bea>, Integer, Integer
 *
 *
 */
void drawBeatHistory(LinkedList<Beat> history, int x, int y)
{
  history.add(new Beat(isHat(), isSnare(), isKick(), isOnset(), getLevel()));
  goalMaxLevel=0;
  for (int i=0; i < history.size(); i++) {
    Beat b = history.get(i);
    if(b.level>goalMaxLevel)
      goalMaxLevel=b.level;
  }
  if(maxLevel<goalMaxLevel)maxLevel+=(goalMaxLevel-maxLevel)/2;
  for (int i=0; i < history.size(); i++) {
    Beat b = history.get(i);

    if (b.hat)
      stroke(120, 100, 100);
    else if (b.snare)
      stroke(220, 100, 100);
    else if (b.kick)
      stroke(320, 100, 100);
    else if (b.onset)
      stroke(0, 0, 100);
    else
      stroke(200, 100, 50);


    float d = 95*b.level/maxLevel;
    line(x+i, y-d, x+i, y);

    if (b.hat)
      stroke(120, 100, 30);
    else if (b.snare)
      stroke(220, 100, 30);
    else if (b.kick)
      stroke(320, 100, 30);
    else if (b.onset)
      stroke(0, 0, 30);
    else
      stroke(200, 100, 30);

    float e = 20*b.level/maxLevel;
    line(x+i, y+e, x+i, y);
  }
  if (history.size()>= 343)
    history.removeFirst();
  stroke(50, 20, 60);
  float n = (minLevelSlider.getValue()/maxLevel*95);
  if(n>98)
  {
    stroke(50, 20, 30); 
    n=98;
  }
  line(x, y-n, x+343, y-n);
  stroke(0);
  maxLevel*=0.99;

}

void drawFrequencies(int x, int y){
  float freqSum=0;
  int linesize = int(lineSizeSlider.getValue());
  
  noStroke();
  fill(200, 100, 20);
  rect(x, y+32, 345, -132);
  fft.forward(buffer.add(in.mix));
  int i;
  fill(0,30,100);
  freqSum=0;
  maxIndex = 0;
  maxFreq = 0;
  for(i = 0; i < fft.specSize(); i++)
  {
    float freq =  fft.getBand(i);
    if(freq>=maxFreq){maxFreq=freq;maxIndex=i;}
    freqSum += freq;
    if(x+i*linesize+linesize>350)break;
  }
  noStroke();
  for(i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    float freq =  fft.getBand(i);
    
    fill(200,100,100);
    if(i==maxIndex){fill(120,100,100);}
    rect(x+i*linesize, y-freq/3, linesize,freq/3);
    fill(200,100,30);
     if(i==maxIndex){fill(120,30,30);}
    rect(x+i*linesize, y, linesize,freq/5);
    if(x+i*linesize+linesize>350)break;
  }
 
  if(getLevel()<0.01)maxIndex*=0.8;
  meanMaxIndex = ((meanMaxIndex*smoothnesSlieder.getValue())+maxIndex)/(smoothnesSlieder.getValue()+1);
  
  stroke(0, 0, 100);
  rect(x+meanMaxIndex*linesize, y, linesize, 30);
  
  fill(255);
}

void initControls()
{
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Monospace", 12));

  displays = cp5.addDropdownList("display").setPosition(10, 61).setSize(255, 150);
  displays.setItemHeight(50).setBarHeight(50);
  displays.captionLabel().set("Select Video Out").align(ControlP5.CENTER, ControlP5.CENTER);
  for (int i = 0; i < gs.length; i++)
  {
    DisplayMode dm = gs[i].getDisplayMode();
    displays.addItem(dm.getWidth()+"x"+dm.getHeight()+"@"+((dm.getRefreshRate() == 0) ? 60 : dm.getRefreshRate()) +"Hz", i);
  }
  // displays.setValue(gs.length-1);

  projectorToggle = cp5.addToggle("Projector").setPosition(270, 10).setSize(135, 50);
  projectorToggle.getCaptionLabel().set("Start Projector").align(ControlP5.CENTER, ControlP5.CENTER);

  beatDelaySlider = cp5.addSlider("beatDelay").setSize(395, 20).setPosition(10, 194).setRange(10, 1000);
  beatDelaySlider.getCaptionLabel().set("Beat Delay (ms)").align(ControlP5.CENTER, ControlP5.CENTER);
  beatDelaySlider.setValue(200);

  minLevelSlider = cp5.addSlider("minLevel").setSize(10, 122).setPosition(354, 70).setRange(0, 1);
  minLevelSlider.setLabelVisible(false);
  minLevelSlider.setValue(0.1);
  
  lineSizeSlider = cp5.addSlider("lineSize").setSize(395, 20).setPosition(10, 238).setRange(1, 64);
  lineSizeSlider.getCaptionLabel().set("fft element count").align(ControlP5.CENTER, ControlP5.CENTER);
  lineSizeSlider.setValue(8);
  
  smoothnesSlieder = cp5.addSlider("smooth").setSize(395, 20).setPosition(10, 216).setRange(0, 200);
  smoothnesSlieder.getCaptionLabel().set("color change delay / ageing").align(ControlP5.CENTER, ControlP5.CENTER);
  smoothnesSlieder.setValue(40);
}

void initRandomControls() {
  randomToggle = cp5.addToggle("random").setSize(135, 45).setPosition(415, 10);
  randomToggle.getCaptionLabel().set("Play Random").align(ControlP5.CENTER, ControlP5.CENTER);

  randomTimeSlider = cp5.addSlider("randomTime").setSize(210, 45).setPosition(555, 10).setRange(1, 60);
  randomTimeSlider.getCaptionLabel().set("Random Time (s)").align(ControlP5.CENTER, ControlP5.CENTER);
  randomTimeSlider.setValue(20);

  nextButton = cp5.addButton("next").setSize(350, 45).setPosition(415, 60);
  nextButton.getCaptionLabel().set("Next Effect").align(ControlP5.CENTER, ControlP5.CENTER);

  activeEffect = cp5.addRadioButton("activeEffects").setPosition(415, 115).setSize(250, 45).setItemsPerRow(1).setSpacingRow(5).setNoneSelectedAllowed(true);
  activeSetting = cp5.addRadioButton("activeSettings").setPosition(720, 115).setSize(45, 45).setItemsPerRow(1).setSpacingRow(5);
}

void Projector(boolean trigger)
{
  if (trigger && stage == null) {
    stage = new Stage (this, int(displays.getValue()));
    stage.stop();
    initEffects();
    stage.start();
    projectorToggle.setCaptionLabel("Stop Projector");
  }
  else if (trigger && stage != null) {
    stage.frame.setVisible(true);
    stage.start();
    projectorToggle.setCaptionLabel("Stop Projector");
  }
  else {
    stage.stop();
    stage.frame.setVisible(false);
    projectorToggle.setCaptionLabel("Start Projector");
  }
}

void initEffects()
{
  initRandomControls();

  effectArray = new Effect[9];
  effectArray[0] = new Blackout_Effect(this, 0);
  effectArray[1] = new Strobe_Effect(this, 1);
  effectArray[2] = new Scanner_Effect(this, 2);
  effectArray[3] = new Moonflower_Effect(this, 3);
  effectArray[4] = new RGBSpot_Effect(this, 4);
  effectArray[5] = new Derby_Effect(this, 5);
  effectArray[6] = new Snowstorm_Effect(this, 6);
  effectArray[7] = new LaserBurst_Effect(this, 7);
  effectArray[8] = new Polygon_Effect(this, 8);

  activeSetting.activate(0);

  for (Toggle t:activeEffect.getItems())
    t.getCaptionLabel().align(LEFT, CENTER);

  for (Toggle t:activeSetting.getItems())
    t.getCaptionLabel().set("EDIT").align(CENTER, CENTER);

  frame.setResizable(true);
  frame.setSize(790, 777);
}


void beatDetect()
{
  bdSound.setSensitivity(int(beatDelaySlider.getValue()));
  bdFreq.setSensitivity(int(beatDelaySlider.getValue()));
  bdSound.detect(in.mix);
  bdFreq.detect(in.mix);
}

void checkForUpdate()
{
  String[] currentVersion = loadStrings("http://musicbeam.zepplab.net/builds/LATEST");

  if (currentVersion!=null)
    if (!currentVersion[0].toLowerCase().equals(version.toLowerCase()))
      open("http://musicbeam.zepplab.net/#update");
}

void keyPressed()
{
  if (effectArray!=null)
    for (int i = 0; i < effectArray.length; i++)
    {
      if (key == effectArray[i].triggeredByKey())
        effectArray[i].activate();
      if (effectArray[i].isActive())
        effectArray[i].keyPressed(key, keyCode);
    }
}

void keyReleased()
{

  if (effectArray!=null)
    for (int i = 0; i < effectArray.length; i++)
      if (effectArray[i].isActive())
        effectArray[i].keyReleased(key, keyCode);
}

boolean isHat()
{
  return getLevel()>minLevelSlider.getValue()?bdFreq.isHat():false;
}

boolean isSnare()
{
  return getLevel()>minLevelSlider.getValue()?bdFreq.isSnare():false;
}

boolean isKick()
{
  return getLevel()>minLevelSlider.getValue()?bdFreq.isKick():false;
}

boolean isOnset()
{
  return getLevel()>minLevelSlider.getValue()?bdSound.isOnset():false;
}

float getLevel()
{
  if(in.mix.level()<0.0001)return 0;
  return in.mix.level();
}
