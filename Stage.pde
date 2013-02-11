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

import processing.opengl.*;
import java.awt.GraphicsDevice;
import java.awt.DisplayMode;
import java.awt.Frame;
import javax.media.opengl.GL;

public class Stage extends PApplet {
  
  MusicBeam ctrl = null;

  int width;

  int height;

  int posx;

  float t = 0.0f;

  float maxRadius;

  float minRadius;

  DisplayMode dm;

  PGraphicsOpenGL pgl;


  Stage (MusicBeam main, int gd)
  {
    super();
    ctrl = main;

    dm = gs[gd].getDisplayMode();

    width = dm.getWidth();
    height = dm.getHeight();
    posx = 0;
    for (int i=0; i<gd; i++)
      posx+= ctrl.gs[i].getDisplayMode().getWidth();
    frame = new Frame( );
    frame.setBounds( posx, 0, width, height );
    frame.removeNotify(); 
    frame.setUndecorated(true); 
    frame.addNotify();
    frame.add(this);
    this.init();
    frame.show();
    maxRadius = sqrt(sq(width)+sq(height));
    minRadius = height < width ? height : width;
  }

  void setup() {
    frameRate(getRefreshRate());
    pgl = (PGraphicsOpenGL) g;
    noStroke();
    colorMode(HSB, 360, 100, 100);
  }

  public void draw() {
    ctrl.beatDetect();
    background(0);

    if (ctrl.debugMode) {
      fill(120, 100, 100);
      textSize(30);
      text(frameRate, 100, 100);
    }

    enableGLBlending();

    translate(width/2, height/2);
    for (int i = 0; i < effectArray.length; i++)
      if (effectArray[i].isActive())
        effectArray[i].refresh();
  }

  /**
   * Enables GLBlending and sets a function to blend overlaying colors.
   *
   */
  private void enableGLBlending() {
    GL gl = pgl.beginGL(); 
    gl.glDisable(GL.GL_DEPTH_TEST);
    gl.glEnable(GL.GL_BLEND);
    gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
    pgl.endGL();
  }

  public int sketchWidth() {
    return dm.getWidth();
  }

  public int sketchHeight() {
    return dm.getHeight();
  }

  public String sketchRenderer() {
    return OPENGL;
  }

  /**
   * Returns the Monitor/Projectors refresh rate.
   * @see java.awt.DisplayMode
   * @return Int
   */
  public int getRefreshRate() {
    return dm.getRefreshRate() < 30 ? 60 : dm.getRefreshRate();
  }

  boolean sketchFullScreen() {
    return true;
  }
}

