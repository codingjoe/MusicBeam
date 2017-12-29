import processing.core.PApplet;
import processing.core.PSurface;

public class Stage extends PApplet {

  MusicBeam ctrl = null;

  Stage (MusicBeam main)
  {
    super();
    ctrl = main;
  }

  public void settings() {
    pixelDensity(displayDensity());
    if (ctrl.debugMode) {
      size(800, 600, P2D);
    } else {
      fullScreen(P2D, 2);
    }
  }

  public void setup() {
    colorMode(HSB, 360, 100, 100);
    try {
      blendMode(ADD);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void draw() {
    ctrl.beatDetect();
    background(0);
    noStroke();

    if (ctrl.debugMode) {
      fill(120, 100, 100);
      textSize(30);
      text(frameRate, 100, 100);
    }

    translate(width/2, height/2);
    for (int i = 0; i < effectArray.length; i++)
      if (effectArray[i].isActive())
        effectArray[i].refresh();
  }
  
  public int getMaxRadius(){
    return int(sqrt(sq(width)+sq(height)));
  }
  
   public int getMinRadius(){
     return height < width ? height : width;
   }
}