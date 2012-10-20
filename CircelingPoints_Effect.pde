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

public class CircelingPoints_Effect extends Effect
{
  float _rotation = 0;

  int _direction = 1;

  Slider weightSlider, speedSlider, hueSlider, pointSlider;

  Toggle aHueToggle, bwToggle;
  
  int winHeight = 200;

  CircelingPoints_Effect(MusicBeam controller)
  {
    super(controller);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(10, 45).setSize(180, 20).setRange(0, 300).moveTo(win);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(50);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(10, 70).setSize(180, 20).setRange(0, 0.1).moveTo(win);
    speedSlider.getCaptionLabel().set("speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(0.02);

    pointSlider = cp5.addSlider("point"+getName()).setPosition(10, 95).setSize(180, 20).setRange(2, 50).moveTo(win);
    pointSlider.getCaptionLabel().set("points").align(ControlP5.RIGHT, ControlP5.CENTER);
    pointSlider.setValue(8);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(155, 20).setPosition(35, 170).moveTo(win);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(10, 170).setSize(20, 20).moveTo(win);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
  }

  String getName()
  {
    return "Circeling Points";
  }

  void draw()
  {
    rotate(_rotation);
    stg.fill(hueSlider.getValue()%360, 100, 100);

    int pts = int(pointSlider.getValue());

    float _radius = stg.minRadius/2-(2*weightSlider.getValue());

    float slice = 2 * PI / pts;
    for (int i = 0; i < pts; i++) {
      float angle = slice * i;
      stg.noStroke();
      stg.ellipse((weightSlider.getValue()+_radius)*cos(angle), (weightSlider.getValue()+_radius)*sin(angle), weightSlider.getValue(), weightSlider.getValue());
    }

    if (isHat())
      _rotation -= _direction*0.001;
    else if (isSnare())
    {
      _direction = -1*_direction;
      _rotation += -_direction*speedSlider.getValue()*2;
    }
    else
      _rotation += _direction*speedSlider.getValue();

    if (aHueToggle.getState() && isKick() && isOnset())
      hueSlider.setValue((hueSlider.getValue()+60)%360);
  }
}

