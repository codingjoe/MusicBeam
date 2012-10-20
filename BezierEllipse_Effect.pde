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

class BezierEllipse_Effect extends Effect
{
  String getName()
  {
    return "BezierEllipse";
  }
  
  int winHeight = 200;

  float[] px, py, pxs, pys, cx, cy, cx2, cy2, cxs, cys, cx2s, cy2s;

  int points = 8;

  float rotation = 0;

  float radius = 400;

  float controlradius = 300;

  Slider weightSlider;

  BezierEllipse_Effect(MusicBeam controller)
  {
    super(controller);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(10, 45).setSize(180, 20).setRange(0, 100).moveTo(win);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(20);
  }

  void draw() {

    setEllipse();
    rotate(rotation);
    for (int i=0; i < points; i++) {
      stg.fill(( i* int(360 / points))%360, 100, 100);
      if (i==points-1) {
        stg.beginShape();
        stg.vertex(px[i], py[i]);
        stg.bezierVertex(cx[i], cy[i], cx2[i], cy2[i], px[0], py[0]);
        stg.vertex(pxs[0], pys[0]);
        stg.bezierVertex(cx2s[i], cy2s[i], cxs[i], cys[i], pxs[i], pys[i]);
        stg.endShape();
        stg.fill(((points-1)* int(360 / points))%360, 100, 100);
        stg.ellipse((px[0]-pxs[0])/2+pxs[0], (py[0]-pys[0])/2+pys[0], weightSlider.getValue(), weightSlider.getValue());
      }
      else {
        //bezier(px[i], py[i], cx[i], cy[i], cx2[i], cy2[i], px[i+1], py[i+1]);
        stg.beginShape();
        stg.vertex(px[i], py[i]);
        stg.bezierVertex(cx[i], cy[i], cx2[i], cy2[i], px[i+1], py[i+1]);
        stg.vertex(pxs[i+1], pys[i+1]);
        stg.bezierVertex(cx2s[i], cy2s[i], cxs[i], cys[i], pxs[i], pys[i]);
        stg.endShape();
      }
      stg.fill(( i* int(360 / points))%360, 100, 100);
      stg.ellipse((px[i]-pxs[i])/2+pxs[i], (py[i]-pys[i])/2+pys[i], weightSlider.getValue(), weightSlider.getValue());
    }
    if (isHat())
      rotation += 0.01;
    else
      rotation -= 0.02;
  }

  // fill up arrays with ellipse coordinate data
  void setEllipse() {
    points = points;
    px = new float[points];
    py = new float[points];
    pxs = new float[points];
    pys = new float[points];
    cx = new float[points];
    cy = new float[points];
    cx2 = new float[points];
    cy2 = new float[points];
    cxs = new float[points];
    cys = new float[points];
    cx2s = new float[points];
    cy2s = new float[points];
    float angle = 360.0/points;
    float controlAngle1 = angle/3.0;
    float controlAngle2 = controlAngle1*2.0;
    for ( int i=0; i<points; i++) {
      px[i] = cos(radians(angle))*radius;
      py[i] = sin(radians(angle))*radius;
      cx[i] = cos(radians(angle+controlAngle1))* 
        controlradius/cos(radians(controlAngle1));
      cy[i] = sin(radians(angle+controlAngle1))* 
        controlradius/cos(radians(controlAngle1));
      cx2[i] = cos(radians(angle+controlAngle2))* 
        controlradius/cos(radians(controlAngle1));
      cy2[i] = sin(radians(angle+controlAngle2))* 
        controlradius/cos(radians(controlAngle1));

      pxs[i] = cos(radians(angle))*(radius+weightSlider.getValue());
      pys[i] = sin(radians(angle))*(radius+weightSlider.getValue());  
      cxs[i] = cos(radians(angle+controlAngle1))*(controlradius+weightSlider.getValue())/cos(radians(controlAngle1));
      cys[i] = sin(radians(angle+controlAngle1))*(controlradius+weightSlider.getValue())/cos(radians(controlAngle1));
      cx2s[i] = cos(radians(angle+controlAngle2))*(controlradius+weightSlider.getValue())/cos(radians(controlAngle1));
      cy2s[i] = sin(radians(angle+controlAngle2))*(controlradius+weightSlider.getValue())/cos(radians(controlAngle1));

      //increment angle so trig functions keep chugging along
      angle+=360.0/points;
    }
  }
}

