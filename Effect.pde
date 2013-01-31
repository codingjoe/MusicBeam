/*
 * Copyright (c) 2012-2013 Zepp Lab UG (haftungsbeschränkt) <www.zepplab.net>, Johannes Hoppe <info@johanneshoppe.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the follocontrolGroupg conditions:
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

  Group controlGroup;

  Toggle activeToggle, randomToggle, settingsToggle;
  
  Tab settingsTab;

  float rotationHistory = 0;

  float[] translationHistory = {
    0, 0
  };

  static final int defaultWidth = 400;

  static final int defaultHeight = 300;
  
  int id;

  Effect(MusicBeam controller, int i)
  {
    id = i;
    ctrl = controller;
    stg = controller.stage;
    
    int posy = 115+(i*50);

    controlGroup = cp5.addGroup(getName()+"SettingsGroup").hide().setPosition(10,255).setWidth(395).setHeight(30);
    controlGroup.disableCollapse();
    controlGroup.getCaptionLabel().set(getName()+" Settings").align(ControlP5.CENTER, ControlP5.CENTER);
    
    ctrl.activeEffect.addItem(getName(),i);
    ctrl.activeSetting.addItem("settings"+getName(),i);
    
    randomToggle = cp5.addToggle("random"+getName()).setSize(45, 45).setPosition(670, posy);
    randomToggle.getCaptionLabel().set("RND").align(ControlP5.CENTER, ControlP5.CENTER);
    randomToggle.setState(true);
  }

  abstract String getName();

  abstract void draw();

  void refresh()
  {
    draw();
    resetStage();
  }

  boolean isHat()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdFreq.isHat():false;
  }

  boolean isSnare()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdFreq.isSnare():false;
  }

  boolean isKick()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdFreq.isKick():false;
  }

  boolean isOnset()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdSound.isOnset():false;
  }
  
  int getId()
  {
    return id;
  }

  boolean isActive()
  {
    return activeEffect.getState(id);
  }
  
  void activate() {
    activeEffect.activate(id);
  }
  
  float getLevel()
  {
    return ctrl.in.mix.level();
  }

  void hideControls()
  {
    controlGroup.hide();
  }

  void showControls()
  {
    controlGroup.show();
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
    stg.translate(-translationHistory[0], -translationHistory[1]);
    translationHistory[0] = 0;
    translationHistory[1] = 0;
  }
  
  void resetStage()
  {
    resetTranslation();
    resetRotation();
  }
}

