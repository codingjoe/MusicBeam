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

public class Moonflower_Effect extends Effect
{
  float rotation = 0;

  int direction = 1;

  Slider radiusSlider, speedSlider, hueSlider, pointSlider;

  Toggle aHueToggle, stereoToggle, bwToggle;

  int winHeight = 200;

  int pts = 10;

  float[] rx = {
    0, 0
  };

  float[] ry = {
    0, 0
  };

  float timer = 0;

  Moonflower_Effect(MusicBeam controller, int y)
  {
    super(controller, y);

    radiusSlider = cp5.addSlider("radius"+getName()).setPosition(0, 5).setSize(395, 45).setRange(0, stg.minRadius/2).moveTo(win);
    radiusSlider.getCaptionLabel().set("Radius").align(ControlP5.RIGHT, ControlP5.CENTER);
    radiusSlider.setValue(stg.minRadius/3);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(0, 55).setSize(395, 45).setRange(0.01, 1).moveTo(win);
    speedSlider.getCaptionLabel().set("speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(0.5);

    stereoToggle = cp5.addToggle("stereo"+getName()).setPosition(0, 105).setSize(395, 45).moveTo(win);
    stereoToggle.getCaptionLabel().set("Bi-Color").align(ControlP5.RIGHT, ControlP5.CENTER);
    stereoToggle.setState(true);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(295, 45).setPosition(50, 155).moveTo(win);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 155).setSize(45, 45).moveTo(win);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);

    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(350, 155).setSize(45, 45).moveTo(win);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(false);

    float radius = radiusSlider.getValue();
    rx[0] = random(radius*5/4, stg.width-radius*5/4);
    ry[0] = random(radius*5/4, stg.height-radius*5/4);
    rx[1] = random((1-direction)/4*radius*5/4, stg.width-radius*5/4);
    ry[1] = random((1-direction)/4*radius*5/4, stg.height-radius*5/4);
  }

  String getName()
  {
    return "Moonflower";
  }

  void draw()
  {
    float radius = radiusSlider.getValue();

    float speed = (1-speedSlider.getValue())*stg.refreshRate;

    if (timer<=0 && isKick()) {
      if (aHueToggle.getState())
        hueSlider.setValue((hueSlider.getValue()+120)%360);
      direction = -1*direction;
      rx[0] = rx[1];
      ry[0] = ry[1];
      rx[1] = random((1-direction)/4*stg.width+radius*5/4, stg.width-radius*5/4-(1-direction)/4*stg.width);
      ry[1] = random((1-direction)/4*stg.height+radius*5/4, stg.height-radius*5/4-(1-direction)/4*stg.height);
      timer = stg.refreshRate*(1-speedSlider.getValue());
    }

    float dx = abs(timer*rx[0]-(timer-speed)*rx[1])/speed;
    float dy = abs(timer*ry[0]-(timer-speed)*ry[1])/speed;

    translate(dx-stg.width/2, dy-stg.height/2);

    rotation = (rotation + 0.01*(direction/(1-speedSlider.getValue())))%(PI*2);

    rotate(rotation);
    stg.fill(hueSlider.getValue()%360, bwToggle.getState()?0:100, 100);

    float slice = 2 * PI / pts;
    for (int i = 0; i < pts; i++) {
      float angle = slice * i;
      stg.ellipse((radius)*cos(angle), (radius)*sin(angle), 0.7*radius/2, 0.7*radius/2);
    }

    if (stereoToggle.getState()) {
      stg.fill((hueSlider.getValue()+120)%360, bwToggle.getState()?0:100, 100);
      rotate(-2*rotation);
    }
    float slice2 = 2 * PI / (pts/2);
    for (int i = 0; i < pts/2; i++) {
      float angle = slice2 * i + slice/2;
      stg.ellipse((radius/2)*cos(angle), (radius/2)*sin(angle), 0.7*radius/2, 0.7*radius/2);
    }
    stg.fill(hueSlider.getValue()%360, bwToggle.getState()?0:100, 100);
    stg.ellipse(0, 0, 0.7*radius/2, 0.7*radius/2);

    if (timer>=0)
      timer--;
  }
}

