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

class Scanner_Effect extends Effect
{ 

  Scanner_Effect(MusicBeam controller)
  {
    super(controller, Effect.defaultWidth, 120);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(10, 45).setSize(180, 20).setRange(0, 100).moveTo(win);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(20);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(10, 70).setSize(180, 20).setRange(0, 0.05).moveTo(win);
    speedSlider.getCaptionLabel().set("speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(0.01);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(155, 20).setPosition(35, 95).moveTo(win);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(10, 95).setSize(20, 20).moveTo(win);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
  }

  public String getName()
  {
    return "Scanner";
  }

  float rotation = 0.0f;

  Slider weightSlider, speedSlider, hueSlider;

  Toggle aHueToggle, bwToggle;

  void draw()
  {

    stg.fill(hueSlider.getValue(), 100, 100);

    rotation = (rotation+speedSlider.getValue())%(9*PI);

    if (rotation<PI)
      rotateRight();
    else if (rotation<PI*7/4)
      rotateLeft();
    else if (rotation<PI*3)
      rotateOpposite();
    else if (rotation<PI*4)
      LinesDissolve();
    else if (rotation<PI*5)
      LinesJoin();
    else if (rotation<PI*6)
    {
      rotate(PI/2);
      LinesDissolve();
    } 
    else if (rotation<PI*7)
    {
      rotate(PI/2);
      LinesJoin();
    } 
    else if (rotation<PI*8)
    {
      LinesDissolve();
      rotate(PI/2);
      stg.fill((hueSlider.getValue()+120)%360, 100, 100);
      LinesDissolve();
    } 
    else if (rotation<PI*9)
    {
      LinesJoin();
      rotate(PI/2);
      stg.fill((hueSlider.getValue()+120)%360, 100, 100);
      LinesJoin();
    }

    if (aHueToggle.getState() && isKick() && isOnset() && isHat() && isSnare())
      hueSlider.setValue((hueSlider.getValue()+120)%360);
  }

  void rotateRight()
  {
    rotate(rotation);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    rotate(PI/2);
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void rotateLeft()
  {
    rotate(-rotation);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    rotate(-PI/2);
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void rotateOpposite()
  {
    rotate(rotation);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    rotate(-2*rotation);
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void LinesDissolve()
  {
    translate(0, (stg.height-weightSlider.getValue())*((rotation%PI)/PI)/2);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    translate(0, -(stg.height-weightSlider.getValue())*(rotation%PI/PI));
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void LinesJoin()
  {
    translate(0, (stg.height-weightSlider.getValue())*(1-((rotation%PI)/PI))/2);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    translate(0, -(stg.height-weightSlider.getValue())*(1-((rotation%PI)/PI)));
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }
}

