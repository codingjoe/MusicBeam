import processing.core.PApplet;
import processing.core.PSurface;

public class Stage extends PApplet {

  MusicBeam ctrl = null;

  int posx;

  float t = 0.0f;

  Stage (MusicBeam main)
  {
    super();
    ctrl = main;
  }

  public void settings() {
    fullScreen(P2D, 2);
  }

  public void setup() {
    noStroke();
    colorMode(HSB, 360, 100, 100);
    blendMode(ADD);
  }

  public void draw() {
    ctrl.beatDetect();
    background(0);

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
