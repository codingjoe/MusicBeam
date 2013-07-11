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

class LaserBurst_Effect extends Effect
{ 

  LaserBurst_Effect(MusicBeam controller, int y)
  {
    super(controller, y);

    radiusSlider = cp5.addSlider("radius"+getName()).setGroup(controlGroup).setPosition(0, 5).setSize(395, 45).setGroup(controlGroup);
    radiusSlider.setRange(10, 100).setValue(30);
    radiusSlider.getCaptionLabel().set("Size").align(ControlP5.RIGHT, ControlP5.CENTER);

    speedSlider = cp5.addSlider("speed"+getName()).setRange(0.01, 1).setValue(0.3).setPosition(0, 55).setSize(395, 45).setGroup(controlGroup);
    speedSlider.getCaptionLabel().set("Speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    
    rotationSpeedSlider = cp5.addSlider("rotationspeed"+getName()).setPosition(0, 105).setSize(395, 45).setGroup(controlGroup);
    rotationSpeedSlider.setRange(0, 1).setValue(0.3);
    rotationSpeedSlider.getCaptionLabel().set("Rotation Speed").align(ControlP5.RIGHT, ControlP5.CENTER);

    inverseToggle = cp5.addToggle("inverse"+getName()).setSize(395, 45).setPosition(0, 155).setGroup(controlGroup);
    inverseToggle.getCaptionLabel().set("Inverse").align(ControlP5.CENTER, ControlP5.CENTER);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(295, 45).setPosition(50, 205).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 205).setSize(45, 45).setGroup(controlGroup);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);

    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(350, 205).setSize(45, 45).setGroup(controlGroup);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(true);

    pts = new LinkedList();
  }

  public String getName()
  {
    return "LaserBurst";
  }
  
  char triggeredByKey() {
    return '7';
  }

  Slider radiusSlider, speedSlider, hueSlider, rotationSpeedSlider;

  Toggle aHueToggle, bwToggle, inverseToggle;

  LinkedList<Float[]> pts;

  Boolean rightSide = false;
  
  float rotation = 0;

  void draw()
  {
    rotate(inverseToggle.getState()?rotation:-rotation);
    if (isKick() || effect_manual_triggered) {
      Float[] k = {
        0.0f, random(0, PI)
      };
      pts.add(k);
    }
    for (int i=0; i<pts.size(); i++) {
      Float[] k = pts.get(i);
      stg.fill(hueSlider.getValue(), bwToggle.getState()?0:100, 100);

      float r;
      if (inverseToggle.getState()) {
        r = (1-k[0])*stg.maxRadius;
      } 
      else {
        r = k[0]*stg.maxRadius;
      }

      stg.ellipse(r*cos(k[1]), r*sin(k[1]), radiusSlider.getValue(), radiusSlider.getValue());
      // stg.fill((hueSlider.getValue()+120)%360, bwToggle.getState()?0:100,100);
      stg.ellipse(r*cos(k[1]+PI), r*sin(k[1]+PI), radiusSlider.getValue(), radiusSlider.getValue());
      if (k[0]>=1)
        pts.remove(i);
      else
        k[0]+=speedSlider.getValue()/100;
    }
    if (aHueToggle.getState()&& (isKick()||isSnare()))
      hueSlider.setValue((hueSlider.getValue()+1)%360);
    rotation = (rotation+rotationSpeedSlider.getValue()/20)%PI;
  }
}

