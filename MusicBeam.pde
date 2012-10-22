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

void setup() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  gs = ge.getScreenDevices();


  size(300, 130);
  frame.setTitle("Music Beam 0.1");
  frame.setLocation(0, 0);

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
}

void drawBeatBoard()
{
  fill(200, 100, 20);
  rect(10, 36, 280, 75);
  fill(120, 100, bdFreq.isHat() ? 100 : 20);
  rect(265, 36, 25, 25);
  fill(220, 100, bdFreq.isSnare() ? 100 : 20);
  rect(265, 61, 25, 25);
  fill(320, 100, bdFreq.isKick() ? 100 : 20);
  rect(265, 86, 25, 25);
  fill(0);
  text("H", 273, 53);
  text("S", 275, 78);
  text("K", 274, 103);

  drawBeatHistory(beatHistory, 11, 73);
}

void drawBeatHistory(LinkedList<Beat> history, int x, int y)
{
  for (int i=0; i < history.size(); i++) {
    Beat b = history.get(i);
    stroke(200, 100, 50);
    if (b.hat) {
      stroke(120, 100, 100);
    }

    if (b.snare) {
      stroke(220, 100, 100);
    }

    if (b.kick) {
      stroke(320, 100, 100);
    }

    float d = 32*b.level;
    if (d>beatHistoryMax)
      beatHistoryMax = d;

    int a = int(32*(d/beatHistoryMax));

    line(x+i, y-a, x+i, y+a);
  }
  if (history.size()>= 254)
    history.removeFirst();

  history.add(new Beat(bdFreq.isHat(), bdFreq.isSnare(), bdFreq.isKick(), in.mix.level()));
  stroke(0);
}

void initControlls()
{
  cp5 = new ControlP5(this);

  displays = cp5.addDropdownList("display")
    .setPosition(11, 32)
      .setSize(170, 30);
  displays.setItemHeight(20);
  displays.setBarHeight(20);
  displays.captionLabel().set("Select Display");
  displays.captionLabel().style().marginTop = 5;
  displays.captionLabel().style().marginLeft = 3;
  displays.valueLabel().style().marginTop = 3;
  for (int i = 0; i < gs.length; i++)
  {
    DisplayMode dm = gs[i].getDisplayMode();
    displays.addItem(dm.getWidth()+"x"+dm.getHeight()+"@"+((dm.getRefreshRate() == 0) ? 60 : dm.getRefreshRate()) +"Hz", i);
  }
  displays.setValue(gs.length-1);

  cp5.addToggle("Projector")
    .setCaptionLabel("Start Projector")
      .setPosition(182, 11)
        .setSize(108, 20)
          .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
}

void Projector(boolean trigger)
{
  if (trigger && stage == null) {
    stage = new Stage (this, gs[int(displays.getValue())], false);
    stage.stop();
    initEffects();
    stage.start();
  } 
  else if (trigger && stage != null) {
    stage.frame.setVisible(true);
    stage.start();
  } 
  else {
    stage.stop();
    stage.frame.setVisible(false);
  }
}

void initEffects()
{
  effectArray = new Effect[5];
  effectArray[0] = new Strobo_Effect(this);
  effectArray[1] = new Scanner_Effect(this);
  effectArray[2] = new CircelingPoints_Effect(this);
  effectArray[3] = new BezierEllipse_Effect(this);
  effectArray[4] = new RGBSpot_Effect(this);
}


void beatDetect()
{
  // bdSound.setSensitivity(50);
  // bdFreq.setSensitivity(50);
  bdSound.detect(in.mix);
  bdFreq.detect(in.mix);
}

