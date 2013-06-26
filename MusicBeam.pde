/*
 * Copyright (c) 2012-2013 Zepp Lab UG (haftungsbeschränkt) <www.zepplab.net>, Johannes Hoppe <info@johanneshoppe.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.awt.DisplayMode;

import java.util.LinkedList;

import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

String version = "1.0.1";

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
Slider randomTimeSlider, beatDelaySlider, minLevelSlider;
Button nextButton;
RadioButton activeEffect, activeSetting;

float randomTimer = 0;

int randomEffect = 0;

void setup() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  gs = ge.getScreenDevices();


  size(415, 225);
  frame.setTitle("MusicBeam v"+version);
  frame.setResizable(true);

  Minim minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);

  bdFreq = new BeatDetect(in.bufferSize(), in.sampleRate());
  bdSound = new BeatDetect();


  colorMode(HSB, 360, 100, 100);

  initControls();
  checkForUpdate();
}


void draw() {
  if (stage==null)
    beatDetect();
  background(25);

  noStroke();

  drawBeatBoard();

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


    float d = 130*b.level;
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

    float e = 30*b.level;
    line(x+i, y+e, x+i, y);
  }
  if (history.size()>= 343)
    history.removeFirst();

  history.add(new Beat(isHat(), isSnare(), isKick(), isOnset(), getLevel()));
  stroke(0);
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

  effectArray = new Effect[8];
  strobo = new Strobe_Effect(this, 0);
  effectArray[0] = strobo;
  effectArray[1] = new Scanner_Effect(this, 1);
  effectArray[2] = new Moonflower_Effect(this, 2);
  effectArray[3] = new RGBSpot_Effect(this, 3);
  effectArray[4] = new Derby_Effect(this, 4);
  effectArray[5] = new Snowstorm_Effect(this, 5);
  effectArray[6] = new LaserBurst_Effect(this, 6);
  effectArray[7] = new Polygon_Effect(this, 7);

  activeSetting.activate(0);

  for (Toggle t:activeEffect.getItems())
    t.getCaptionLabel().align(CENTER, CENTER);

  for (Toggle t:activeSetting.getItems())
    t.getCaptionLabel().set("EDIT").align(CENTER, CENTER);

  frame.setResizable(true);
  frame.setSize(775, 615);
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
      if (effectArray[i].isActive())
        effectArray[i].keyPressed(key, keyCode);
}

void keyReleased()
{

  if (effectArray!=null)
    for (int i = 0; i < effectArray.length; i++)
    {
      if (key == effectArray[i].triggeredByKey())
        effectArray[i].activate();
      if (effectArray[i].isActive())
        effectArray[i].keyReleased(key, keyCode);
    }
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
  return in.mix.level();
}

