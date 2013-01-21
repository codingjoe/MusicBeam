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

class Polygon_Effect extends Effect
{
  String getName()
  {
    return "Polygon";
  }

  int winHeight = 200;

  float[] px, py, pxs, pys;


  float rotation = 0;

  float controlradius = 200;

  Toggle aHueToggle, bwToggle;

  Slider weightSlider, pointsSlider, speedSlider, hueSlider, rotationSpeedSlider;

  Polygon_Effect(MusicBeam controller, int y)
  {
    super(controller, Effect.defaultWidth, 220, y);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(0, 100).moveTo(win);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(20);

    pointsSlider = cp5.addSlider("points"+getName()).setPosition(0, 55).setSize(395, 45).setRange(3, 20).moveTo(win);
    pointsSlider.getCaptionLabel().set("Points").align(ControlP5.RIGHT, ControlP5.CENTER);
    pointsSlider.setValue(8);

    rotationSpeedSlider = cp5.addSlider("rotationspeed"+getName()).setPosition(0, 105).setSize(395, 45).moveTo(win);
    rotationSpeedSlider.setRange(-1, 1).setValue(0.3);
    rotationSpeedSlider.getCaptionLabel().set("Rotation Speed").align(ControlP5.RIGHT, ControlP5.CENTER);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(345, 45).setPosition(50, 155).moveTo(win);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 155).setSize(45, 45).moveTo(win);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
  }

  void draw() {

    int points = int(pointsSlider.getValue());
    float weight = weightSlider.getValue();
    float radius = stg.minRadius-weight;
    float c = hueSlider.getValue();

    setEllipse();

    rotate(rotation);
    for (int i=0; i < points; i++) {
      stg.fill((((i%2)==1?120:0)+c)%360, 100, 100);
      if (i==points-1) {
        stg.quad(px[i], py[i], px[0], py[0], pxs[0], pys[0], pxs[i], pys[i]);
        stg.fill(-1);
        stg.ellipse((px[0]-pxs[0])/2+pxs[0], (py[0]-pys[0])/2+pys[0], 1.5*weight, 1.5*weight);
      }
      else {
        stg.quad(px[i], py[i], px[i+1], py[i+1], pxs[i+1], pys[i+1], pxs[i], pys[i]);
      }
      stg.fill(-1);
      stg.ellipse((px[i]-pxs[i])/2+pxs[i], (py[i]-pys[i])/2+pys[i], 1.5*weight, 1.5*weight);
    }
    rotation = (rotation+rotationSpeedSlider.getValue()/20)%(2*PI);

    if (aHueToggle.getState()&& (isKick()&&isSnare()))
      hueSlider.setValue((hueSlider.getValue()+120)%360);
  }

  // fill up arrays with ellipse coordinate data
  void setEllipse() {
    int points = int(pointsSlider.getValue());
    float weight = weightSlider.getValue();
    float radius = stg.minRadius/2-1.5*weight;
    px = new float[points];
    py = new float[points];
    pxs = new float[points];
    pys = new float[points];
    float angle = 360.0/points;
    for ( int i=0; i<points; i++) {
      px[i] = cos(radians(angle))*radius;
      py[i] = sin(radians(angle))*radius;
      pxs[i] = cos(radians(angle))*(radius+weightSlider.getValue());
      pys[i] = sin(radians(angle))*(radius+weightSlider.getValue());  
      angle+=360.0/points;
    }
  }
}

