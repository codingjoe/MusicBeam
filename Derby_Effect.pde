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

class Derby_Effect extends Effect
{
  String getName() {
    return "Derby";
  }
  
  Slider weightSlider, speedSlider, pointSlider, hueSlider;
  
  Toggle aHueToggle, mirrorToggle;
  
  float rotation = 0;

  Derby_Effect(MusicBeam ctrl)
  {
    super(ctrl, Effect.defaultWidth, 175, 115);
    
    weightSlider = cp5.addSlider("weight"+getName()).setPosition(10, 45).setSize(180, 20).setRange(0, 200).moveTo(win);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(80);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(10, 70).setSize(180, 20).setRange(0, 1).moveTo(win);
    speedSlider.getCaptionLabel().set("speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(0.25);

    pointSlider = cp5.addSlider("point"+getName()).setPosition(10, 95).setSize(180, 20).setRange(1, 20).moveTo(win);
    pointSlider.getCaptionLabel().set("points").align(ControlP5.RIGHT, ControlP5.CENTER);
    pointSlider.setValue(4);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(155, 20).setPosition(35, 145).moveTo(win);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(10, 145).setSize(20, 20).moveTo(win);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
    
    mirrorToggle = cp5.addToggle("mirror"+getName()).setPosition(10, 120).setSize(180, 20).moveTo(win);
    mirrorToggle.getCaptionLabel().set("Mirror").align(ControlP5.CENTER, ControlP5.CENTER);
    mirrorToggle.setState(true);
  }

  void draw()
  {
    float width = stg.width-weightSlider.getValue();
    float height = stg.height-weightSlider.getValue();
    float points = int(pointSlider.getValue());
    
    translate(-stg.width/2, -stg.height/2);
    stg.fill(hueSlider.getValue(), 100, 100);
    for (int i=1;i<=points;i++)
    {
      stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)+cos(rotation)*width/(points+1), weightSlider.getValue()/2+height/3-height/3*sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
    }
    if (mirrorToggle.getState())
      for (int i=1;i<=points;i++)
      {
        stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)-cos(rotation)*width/(points+1), weightSlider.getValue()/2+height/3-height/3*sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
      }
    
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    for (int i=1;i<=points;i++)
    {
      stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)+cos(rotation)*width/(points+1), weightSlider.getValue()/2+2*height/3-height/3*-sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
    }
    
    if (mirrorToggle.getState())
    for (int i=1;i<=points;i++)
    {
      stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)-cos(rotation)*width/(points+1), weightSlider.getValue()/2+2*height/3-height/3*-sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
    }
    
    if (aHueToggle.getState()&&isOnset()&&isKick()&&isHat()&&isSnare())
      hueSlider.setValue((hueSlider.getValue()+120)%360);
      
    rotation = (rotation + getLevel()*speedSlider.getValue())%(2*PI);
  }
}

