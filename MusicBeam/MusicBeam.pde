import java.util.LinkedList;

import javax.swing.JOptionPane;

import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;

import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

String version = "2.4.0";

public Boolean debugMode = false;

Stage stage = null;

Strobe_Effect strobo;

ControlP5 cp5;

Minim minim;

AudioSource in;

BeatDetect bdFreq, bdSound;

PImage[] randomImg;

LinkedList<Beat> beatHistory = new LinkedList();

Effect[] effectArray;

DropdownList displays;

Toggle projectorToggle, randomToggle;
Slider randomTimeSlider, beatDelaySlider, minLevelSlider;
Button nextButton;
RadioButton activeEffect, activeSetting;

float randomTimer = 0;

int randomEffect = 0;
int width = 775;
int height = 570;

float maxLevel = 0;
float goalMaxLevel=0;
void settings() {
  pixelDensity(displayDensity());
  initAudioInput();

  if(!hasEnoughScreenDevices()) {
      String msg = "No second screen device detected!\n"
        +"Please make sure to attach your video projector before you launch MusicBeam.\n"
        +"Do you want to launch MusicBeam anyway?";
      int close = JOptionPane.showConfirmDialog(null, msg, "Device detection", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);
      if (close == JOptionPane.NO_OPTION)
        System.exit(1);
    }

  size(width, height);
}

void setup() {
  surface.setTitle("MusicBeam v"+version);
  
  colorMode(HSB, 360, 100, 100);

  initControls();
  if (! debugMode)
    checkForUpdate();
}


void draw() {
  if (stage==null)
    beatDetect();
  background(25);

  noStroke();

  drawBeatBoard();

  if (effectArray!=null) {
    for (Effect e : effectArray)
      e.hideControls();
    if (int(activeSetting.getValue())>=0)
      effectArray[int(activeSetting.getValue())].showControls();
  }

  if (randomToggle!=null)
    if (randomToggle.getState()&&randomTimer>=randomTimeSlider.getValue()*60)
    {
      nextRandom();
    } else if (randomToggle.getState())
      randomTimer++;
}

void nextRandom()
{
  int k = randomEffect;
  while (randomEffect==k || !effectArray[k].randomToggle.getState())
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
  rect(10, 10, 354, 122);
  fill(120, 100, getLevel()>minLevelSlider.getValue()&&bdFreq.isHat() ? 100 : 20);
  rect(365, 10, 40, 40);
  fill(220, 100, getLevel()>minLevelSlider.getValue()&&bdFreq.isSnare() ? 100 : 20);
  rect(365, 51, 40, 40);
  fill(320, 100, getLevel()>minLevelSlider.getValue()&&bdFreq.isKick() ? 100 : 20);
  rect(365, 92, 40, 40);
  fill(0);

  textSize(32);
  textAlign(CENTER, CENTER);
  text("H", 385, 26);
  text("S", 385, 67);
  text("K", 385, 108);
  textAlign(LEFT, BOTTOM);
  drawBeatHistory(beatHistory, 10, 110);
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
    if (b.level>goalMaxLevel)
      goalMaxLevel=b.level;
  }
  if (maxLevel<goalMaxLevel)maxLevel+=(goalMaxLevel-maxLevel)/2;
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
  float level = minLevelSlider.getValue();
  if (level*5 > maxLevel*4) {
    minLevelSlider.setValue(level*0.99);
  } else if (level*5 < maxLevel) {
    minLevelSlider.setValue(level*1.01);
  }
  if (n>98)
  {
    stroke(50, 20, 30);
    n=98;
  }
  line(x, y-n, x+343, y-n);
  stroke(0);
  maxLevel*=0.99;
}

void initControls()
{
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Monospace", 12 / displayDensity()));
  beatDelaySlider = cp5.addSlider("beatDelay").setSize(395, 20).setPosition(10, 134).setRange(10, 1000);
  beatDelaySlider.getCaptionLabel().set("Beat Delay (ms)").align(ControlP5.CENTER, ControlP5.CENTER);
  beatDelaySlider.setValue(200);

  minLevelSlider = cp5.addSlider("minLevel").setSize(10, 122).setPosition(354, 10).setRange(0, 1);
  minLevelSlider.setLabelVisible(false);
  minLevelSlider.setValue(0.1);

  stage = new Stage(this);
  String[] args = {"Stage"};
  PApplet.runSketch(args, stage);
  stage.noLoop();
  initEffects();
  initSettings();
  stage.loop();
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

  for (Toggle t : activeEffect.getItems())
    t.getCaptionLabel().align(LEFT, CENTER);

  for (Toggle t : activeSetting.getItems())
    t.getCaptionLabel().set("EDIT").align(CENTER, CENTER);
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
  String[] lines = loadStrings("https://api.github.com/repos/codingjoe/musicbeam/releases/latest");
  if (lines!=null) {
    String jsonString = "";
    for (int i = 0; i < lines.length; i++) {
      jsonString += lines[i];
    }
    JSONObject json = parseJSONObject(jsonString);
    if (!json.getString("tag_name").toLowerCase().equals(version.toLowerCase()))
      launch("http://www.musicbeam.org/#update");
  }
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
  if (in.mix.level()<0.0001)return 0;
  return in.mix.level();
}

private boolean hasEnoughScreenDevices()
{
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment(); //<>// //<>//
  GraphicsDevice[] gs = ge.getScreenDevices();
  return gs.length > 1;
}

private void initAudioInput()
{
  String msg = "No audio input found!\n\n"
             + "Please check the audio settings on your current operating system.\n"
             + "There must be at least one audio input activated.";

  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);

  if(in == null)
  {
    JOptionPane.showMessageDialog(null, msg, "Device detection", JOptionPane.ERROR_MESSAGE);
    System.exit(1);
  }

  bdFreq = new BeatDetect(in.bufferSize(), in.sampleRate());
  bdSound = new BeatDetect();
}