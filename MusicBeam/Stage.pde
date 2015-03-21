import java.awt.GraphicsDevice;
import java.awt.DisplayMode;
import java.awt.Frame;
import javax.media.opengl.GL2;

public class Stage extends PApplet {
  
  MusicBeam ctrl = null;

  int width;

  int height;

  int posx;

  float t = 0.0f;

  float maxRadius;

  float minRadius;

  DisplayMode dm;
  
  GL2 gl;

  Stage (MusicBeam main, int gd)
  {
    super();
    ctrl = main;

    dm = gs[gd].getDisplayMode();

    width = this.sketchWidth();
    height = this.sketchHeight();
    posx = 0;
    for (int i=0; i<gs.length; i++)
      posx+= ctrl.gs[i].getDisplayMode().getWidth();
    posx -= width;
    frame = new Frame( );
    frame.setBounds(posx, 0, width, height);
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
    gl = ((PJOGL)beginPGL()).gl.getGL2();
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
    gl.glDisable(GL2.GL_DEPTH_TEST);
    gl.glEnable(GL2.GL_BLEND);
    gl.glBlendFunc(GL2.GL_SRC_ALPHA, GL2.GL_ONE);
  }

  public int sketchWidth() {
    return dm.getWidth();
  }

  public int sketchHeight() {
    int value = dm.getHeight();
    String os = System.getProperty("os.name").toLowerCase();
    if (os.indexOf("mac") >= 0) {
      value += 25;
    }
    return value;
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

