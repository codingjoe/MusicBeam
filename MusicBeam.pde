/*
 * Copyright (c) 2012 Zepp Lab UG (haftungsbeschränkt) <www.zepplab.net>, Johannes Hoppe <info@johanneshoppe.com>
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

import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

String version = "0.9";

Stage stage = null;

Strobe_Effect strobo;

GraphicsDevice[] gs;

ControlP5 cp5;

Minim minim;

AudioSource in;

BeatDetect bdFreq, bdSound;

LinkedList<Beat> beatHistory = new LinkedList();

Effect[] effectArray;

float beatHistoryMax = 1;

PFont symFont;

DropdownList displays;

Toggle projectorToggle, randomToggle;
Slider randomTimeSlider;
Button nextButton;
RadioButton activeEffect, activeSetting;

float randomTimer = 0;

int randomEffect = 0;

void setup() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  gs = ge.getScreenDevices();


  size(415, 200);
  frame.setTitle("MusicBeam");
  frame.setLocation(0, 0);
  frame.setResizable(true);
  frameRate(30);

  Minim minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);

  bdFreq = new BeatDetect(in.bufferSize(), in.sampleRate());
  bdSound = new BeatDetect();

  symFont = loadFont("GLYPHICONS-NONFREE.vlw");

  initControlls();

  colorMode(HSB, 360, 100, 100);

  checkForUpdate();
}

void draw() {
  if (stage==null)
    beatDetect();
  smooth();
  background(25);

  noStroke();

  drawBeatBoard();

  if (effectArray!=null) {
    for (Effect e:effectArray)
      e.hideWin();
    if (int(activeSetting.getValue())>=0)
      effectArray[int(activeSetting.getValue())].showWin();
  }

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
  fill(120, 100, bdFreq.isHat() ? 100 : 20);
  rect(365, 70, 40, 40);
  fill(220, 100, bdFreq.isSnare() ? 100 : 20);
  rect(365, 111, 40, 40);
  fill(320, 100, bdFreq.isKick() ? 100 : 20);
  rect(365, 152, 40, 40);
  fill(0);

  textSize(32);
  textAlign(CENTER, CENTER);
  text("H", 385, 88);
  text("S", 385, 129);
  text("K", 385, 170);
  textAlign(LEFT, BOTTOM);
  drawBeatHistory(beatHistory, 10, 130);
}

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


    float d = 60*b.level;
    if (d>beatHistoryMax)
      beatHistoryMax = d;

    int a = int(60*(d/beatHistoryMax));

    line(x+i, y-a, x+i, y+a);
  }
  if (history.size()>= 354)
    history.removeFirst();

  history.add(new Beat(bdFreq.isHat(), bdFreq.isSnare(), bdFreq.isKick(), bdSound.isOnset(), in.mix.level()));
  stroke(0);
}

void initControlls()
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

  randomToggle = cp5.addToggle("random").setSize(135, 45).setPosition(415, 10);
  randomToggle.getCaptionLabel().set("Play Random").align(ControlP5.CENTER, ControlP5.CENTER);
  randomToggle.lock();
  randomToggle.setColorCaptionLabel(50);

  randomTimeSlider = cp5.addSlider("randomTime").setSize(210, 45).setPosition(555, 10).setRange(1, 60);
  randomTimeSlider.getCaptionLabel().set("Random Time (s)").align(ControlP5.CENTER, ControlP5.CENTER);
  randomTimeSlider.setValue(20);
  randomTimeSlider.lock();
  randomTimeSlider.setColorCaptionLabel(50);
  randomTimeSlider.setColorValueLabel(50);

  nextButton = cp5.addButton("next").setSize(350, 45).setPosition(415, 60);
  nextButton.getCaptionLabel().set("Next Effect").align(ControlP5.CENTER, ControlP5.CENTER);
  nextButton.lock();
  nextButton.setColorCaptionLabel(50);

  activeEffect = cp5.addRadioButton("activeEffects").setPosition(415, 115).setSize(250, 45).setItemsPerRow(1).setSpacingRow(5).setNoneSelectedAllowed(true);
  activeSetting = cp5.addRadioButton("activeSettings").setPosition(720, 115).setSize(45, 45).setItemsPerRow(1).setSpacingRow(5);
}

void Projector(boolean trigger)
{
  if (trigger && stage == null) {
    stage = new Stage (this, int(displays.getValue()), false);
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
  frame.setResizable(true);
  frame.setSize(775, 565);
  
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
  for (Toggle t:activeEffect.getItems())
    t.getCaptionLabel().align(CENTER, CENTER);
  for (Toggle t:activeSetting.getItems())
    t.getCaptionLabel().set("").setFont(symFont).align(CENTER, CENTER).style().moveMargin(-4,0,0,0);

  randomToggle.unlock();
  randomToggle.setColorCaptionLabel(-1);
  randomTimeSlider.unlock();
  randomTimeSlider.setColorCaptionLabel(-1);
  randomTimeSlider.setColorValueLabel(-1);
  nextButton.unlock();
  nextButton.setColorCaptionLabel(-1);
}


void beatDetect()
{
  bdSound.setSensitivity(500);
  bdFreq.setSensitivity(500);
  bdSound.detect(in.mix);
  bdFreq.detect(in.mix);
}

void checkForUpdate()
{
  String[] currentVersion = loadStrings("http://musicbeam.zepplab.net/builds/latest");

  if (!currentVersion[0].toLowerCase().equals(version.toLowerCase()))
    open("http://musicbeam.zepplab.net/#update");
}

void keyPressed()
{
  if (effectArray!=null) {
    if (key=='s') {
      strobo.activate();
      strobo.manualButton.setSwitch(true);
      strobo.manualButton.setOn();
    }
    if (key=='n')
      nextRandom();
    if (key==CODED)
      if (keyCode==RIGHT)
        strobo.delaySlider.setValue(strobo.delaySlider.getValue()+1);
      else if (keyCode==LEFT)
        strobo.delaySlider.setValue(strobo.delaySlider.getValue()-1);
  }
}

void keyReleased()
{
  if (effectArray!=null)
    if (key=='s') {
      strobo.manualButton.setOff();
      strobo.manualButton.setSwitch(false);
      nextRandom();
    }
}

