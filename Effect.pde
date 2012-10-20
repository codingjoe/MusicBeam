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

import controlP5.*;
import controlP5.Controller;

public abstract class Effect
{

  MusicBeam ctrl;

  Stage stg;

  ControlWindow win;

  Toggle activeToggle;

  float rotationHistory = 0;

  float[] translationHistory = {
    0, 0
  };

  int winWidth = 200;

  int winHeight = 200;

  Effect(MusicBeam controller)
  {
    ctrl = controller;
    stg = controller.stage;

    win = cp5.addControlWindow(getName(), winWidth, winHeight);
    activeToggle = cp5.addToggle("active"+getName()).setSize(180, 30).setPosition(10, 10).moveTo(win);
    activeToggle.getCaptionLabel().set("Active").align(ControlP5.CENTER, ControlP5.CENTER);
    activeToggle.setState(false);
  }

  abstract String getName();

  abstract void draw();

  void refresh()
  {
    draw();
    resetRotation();
    resetTranslation();
  }

  boolean isHat()
  {
    return ctrl.bdFreq.isHat();
  }

  boolean isSnare()
  {
    return ctrl.bdFreq.isSnare();
  }

  boolean isKick()
  {
    return ctrl.bdFreq.isKick();
  }

  boolean isOnset()
  {
    return ctrl.bdSound.isOnset();
  }

  boolean isActive()
  {
    return activeToggle.getState();
  }

  void hideWin()
  {
    win.hide();
  }

  void showWin()
  {
    win.show();
  }

  void rotate(float r)
  {
    stg.rotate(r);
    rotationHistory+=r;
  }

  void resetRotation()
  {
    stg.rotate(-rotationHistory);
    rotationHistory = 0;
  }

  void translate(float x, float y)
  {
    stg.translate(x, y);
    translationHistory[0]+= x;
    translationHistory[1]+= y;
  }

  void resetTranslation()
  {
    stg.translate(translationHistory[0], translationHistory[1]);
    translationHistory[0] = 0;
    translationHistory[1] = 0;
  }
}

