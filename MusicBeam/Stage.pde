import processing.core.PApplet;
import processing.core.PSurface;

public class Stage extends PApplet {

  MusicBeam ctrl = null;
  ProjectorSimulator sim;

  Stage (MusicBeam main)
  {
    super();
    ctrl = main;
    sim = new ProjectorSimulator();
    
    if(ctrl.debugMode){
    String[] args = {"Simulator"};
    PApplet.runSketch(args, sim);
    }
    
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

    translate(width/2, height/2);
    for (int i = 0; i < effectArray.length; i++)
      if (effectArray[i].isActive())
        effectArray[i].refresh();
    
     if (ctrl.debugMode) {
      resetMatrix();
      PImage img = get();
      sim.setImage(img);
       
      fill(120, 100, 100);
      textSize(30);
      text(frameRate, 100, 100);
    }
  }
  
  public int getMaxRadius(){
    return int(sqrt(sq(width)+sq(height)));
  }
  
   public int getMinRadius(){
     return height < width ? height : width;
   }
}