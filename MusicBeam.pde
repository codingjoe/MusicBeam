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

Stage stage = null;

GraphicsDevice[] gs;

ControlP5 cp5;

Minim minim;

AudioSource in;

BeatDetect bdFreq, bdSound;

LinkedList<Beat> beatHistory = new LinkedList();

Effect[] effectArray;

float beatHistoryMax = 1;

DropdownList displays;

Toggle projectorToggle, randomToggle;
Slider randomTimeSlider;
Button nextButton;

float randomTimer = 0;

void setup() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  gs = ge.getScreenDevices();


  size(775, 580);
  frame.setTitle("MusicBeam 1 powered by ZeppLab");
  frame.setLocation(0, 0);
  frame.setResizable(true);
  frameRate(60);

  Minim minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);

  bdFreq = new BeatDetect(in.bufferSize(), in.sampleRate());
  bdSound = new BeatDetect();
  
  initControlls();

  colorMode(HSB, 360, 100, 100);
}

void draw() {
  if (stage==null)
    beatDetect();
  smooth();
  background(25);

  drawBeatBoard();
  
  if (effectArray!=null)
  for (int i=0; i<effectArray.length; i++)
  {
    if(effectArray[i].settingsToggle.getState())
      effectArray[i].showWin();
    else
      effectArray[i].hideWin();
  }

  if (randomToggle.getState()&&randomTimer<=0)
  {
    for (int i = 1; i<effectArray.length;i++)
      effectArray[i].activeToggle.setState(false);
    effectArray[int(random(1, effectArray.length))].activeToggle.setState(true);
    randomTimer = randomTimeSlider.getValue()*60;
  }
  if (randomTimer>0)
    randomTimer--;
}

void controlEvent(ControlEvent event)
{
  if (event.getName()=="next") {
      for (int i = 1; i<effectArray.length;i++) {
        if (effectArray[i].activeToggle.getState()) {
          effectArray[i].activeToggle.setState(false);
          int k = i;
          do
            k = int(random(1, effectArray.length-1));
          while (i == k);
          effectArray[k].activeToggle.setState(true);
        }
      }
    randomTimer = randomTimeSlider.getValue()*60;
  }
}

void drawBeatBoard()
{
  fill(200, 100, 20);
  rect(10, 70, 380, 122);
  fill(120, 100, bdFreq.isHat() ? 100 : 20);
  rect(365, 70, 40, 40);
  fill(220, 100, bdFreq.isSnare() ? 100 : 20);
  rect(365, 111, 40, 40);
  fill(320, 100, bdFreq.isKick() ? 100 : 20);
  rect(365, 152, 40, 40);
  fill(0);
  
  textSize(32);
  textAlign(CENTER,CENTER);
  text("H", 385, 88);
  text("S", 385, 129);
  text("K", 385, 170);
  textAlign(LEFT,BOTTOM);
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
  cp5.setFont(createFont("Monospace",12));

  displays = cp5.addDropdownList("display").setPosition(10, 62).setSize(255, 150);
  displays.setItemHeight(50).setBarHeight(50);
  displays.captionLabel().set("Select Video Out").align(ControlP5.CENTER,ControlP5.CENTER);
  for (int i = 0; i < gs.length; i++)
  {
    DisplayMode dm = gs[i].getDisplayMode();
    displays.addItem(dm.getWidth()+"x"+dm.getHeight()+"@"+((dm.getRefreshRate() == 0) ? 60 : dm.getRefreshRate()) +"Hz", i);
  }
  // displays.setValue(gs.length-1);

  projectorToggle = cp5.addToggle("Projector").setPosition(272, 10).setSize(133, 50);
  projectorToggle.getCaptionLabel().set("Start Projector").align(ControlP5.CENTER, ControlP5.CENTER);

  randomToggle = cp5.addToggle("random").setSize(135, 50).setPosition(10, 202);
  randomToggle.getCaptionLabel().set("Random Effects").align(ControlP5.CENTER, ControlP5.CENTER);
  randomToggle.lock();
  randomToggle.setColorCaptionLabel(50);

  randomTimeSlider = cp5.addSlider("randomTime").setSize(255, 50).setPosition(150, 202).setRange(1, 60);
  randomTimeSlider.getCaptionLabel().set("Random Time (s)").align(ControlP5.CENTER, ControlP5.CENTER);
  randomTimeSlider.setValue(20);
  randomTimeSlider.lock();
  randomTimeSlider.setColorCaptionLabel(50);
  randomTimeSlider.setColorValueLabel(50);

  nextButton = cp5.addButton("next").setSize(395, 50).setPosition(10, 257);
  nextButton.getCaptionLabel().set("Next Effect").align(ControlP5.CENTER, ControlP5.CENTER);
  nextButton.lock();
  nextButton.setColorCaptionLabel(50);
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
  //frame.setResizable(true);
  //frame.setSize(525,190);
  effectArray = new Effect[8];
  effectArray[0] = new Strobo_Effect(this,0);
  effectArray[1] = new Scanner_Effect(this,1);
  effectArray[2] = new Moonflower_Effect(this,2);
  effectArray[3] = new RGBSpot_Effect(this,3);
  effectArray[4] = new Derby_Effect(this,4);
  effectArray[5] = new Snowstorm_Effect(this,5);
  effectArray[6] = new LaserBurst_Effect(this,6);
  effectArray[7] = new Polygon_Effect(this,7);
  randomToggle.unlock();
  randomToggle.setColorCaptionLabel(-1);
  randomTimeSlider.unlock();
  randomTimeSlider.setColorCaptionLabel(-1);
  randomTimeSlider.setColorValueLabel(-1);
  nextButton.unlock();
  nextButton.setColorCaptionLabel(-1);
  
  //frame.setResizable(false);
}


void beatDetect()
{
  bdSound.setSensitivity(500);
  bdFreq.setSensitivity(500);
  bdSound.detect(in.mix);
  bdFreq.detect(in.mix);
}

