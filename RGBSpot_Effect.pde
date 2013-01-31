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

class RGBSpot_Effect extends Effect
{
  String getName() {
    return "RGB Spot";
  }

  RGBSpot_Effect(MusicBeam ctrl, int y)
  {
    super(ctrl, y);

    manualButton = cp5.addButton("manual"+getName()).setSize(195, 195).setPosition(0, 5).setGroup(controlGroup);
    manualButton.getCaptionLabel().set("Manual Trigger").align(ControlP5.CENTER, ControlP5.CENTER);

    hatToggle = cp5.addToggle("hat"+getName()).setSize(195, 45).setPosition(200, 5).setGroup(controlGroup);
    hatToggle.getCaptionLabel().set("Hat").align(ControlP5.CENTER, ControlP5.CENTER);

    snareToggle = cp5.addToggle("snare"+getName()).setSize(195, 45).setPosition(200, 55).setGroup(controlGroup);
    snareToggle.getCaptionLabel().set("Snare").align(ControlP5.CENTER, ControlP5.CENTER);

    kickToggle = cp5.addToggle("kick"+getName()).setSize(195, 45).setPosition(200, 105).setGroup(controlGroup);
    kickToggle.getCaptionLabel().set("Kick").align(ControlP5.CENTER, ControlP5.CENTER);
    kickToggle.setState(true);

    onsetToggle = cp5.addToggle("onset"+getName()).setSize(195, 45).setPosition(200, 155).setGroup(controlGroup);
    onsetToggle.getCaptionLabel().set("Peak").align(ControlP5.CENTER, ControlP5.CENTER);
    onsetToggle.setState(true);

    delaySlider = cp5.addSlider("delay"+getName()).setRange(0.01,1).setValue(0.3).setPosition(0, 205).setSize(395, 45).setGroup(controlGroup);
    delaySlider.getCaptionLabel().set("Speed").align(ControlP5.RIGHT, ControlP5.CENTER);

    radiusSlider = cp5.addSlider("radius"+getName()).setRange(0, 1).setValue(0.3).setPosition(0, 255).setSize(395, 45).setGroup(controlGroup);
    radiusSlider.getCaptionLabel().set("Radius").align(ControlP5.RIGHT, ControlP5.CENTER);
  }

  float[] rx = {0,0};
  float[] ry = {0,0};
  float[] rc = {0,0};

  float timer = 0;
  
  float fader = 0;

  Button manualButton;

  Toggle hatToggle, snareToggle, kickToggle, onsetToggle;

  Slider delaySlider, radiusSlider;

  float radius = 0;

  void draw()
  {
    radius = stg.minRadius*radiusSlider.getValue();
    translate(-stg.width/2, -stg.height/2);

    if ((isTriggered()&&timer<=0)) {
      rx[1] = rx[0];
      ry[1] = ry[0];
      rc[1] = rc[0];
      rx[0] = random(radius/2, stg.width-radius/2);
      ry[0] = random(radius/2, stg.height-radius/2);
      while(rc[0]==rc[1])
        rc[0] = random(0, 6);
      timer = delaySlider.getValue()*stg.frameRate*3;
      fader = stg.frameRate/4;
    }

    stg.fill(60*rc[0], 100, 100);
    stg.ellipse(rx[0], ry[0], radius, radius);
    translate(stg.width, stg.height);
    stg.ellipse(-rx[0], -ry[0], radius, radius);
    translate(-stg.width, -stg.height);
    stg.fill(60*rc[1], 100, 5*fader);
    stg.ellipse(rx[1], ry[1], radius, radius);
    translate(stg.width, stg.height);
    stg.ellipse(-rx[1], -ry[1], radius, radius);

    if (timer>0)
      timer--;
    if (fader>0)
      fader--;
  }

  boolean isTriggered()
  {
    if (manualButton.isPressed())
      return true;
    else if ((!onsetToggle.getState() && hatToggle.getState() && isHat()) || (onsetToggle.getState() && isOnset() && hatToggle.getState() && isHat()))
      return true;
    else if ((!onsetToggle.getState() && snareToggle.getState() && isSnare()) || (onsetToggle.getState() && isOnset() && snareToggle.getState() && isSnare()))
      return true;
    else if ((!onsetToggle.getState() && kickToggle.getState() && isKick()) || (onsetToggle.getState() && isOnset() && kickToggle.getState() && isKick()))
      return true;
    else if (onsetToggle.getState() && isOnset())
      return true;
    else
      return false;
  }
}

