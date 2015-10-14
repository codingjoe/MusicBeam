class Polygon_Effect extends Effect
{
  String getName()
  {
    return "Polygon";
  }
  
  char triggeredByKey() {
    return '8';
  }

  int winHeight = 200;

  float[] px, py, pxs, pys;


  float rotation = 0;

  float controlradius = 200;

  Toggle aHueToggle, bwToggle;

  Slider weightSlider, pointsSlider, speedSlider, hueSlider, rotationSpeedSlider;

  Polygon_Effect(MusicBeam controller, int y)
  {
    super(controller, y);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(0, 100).setGroup(controlGroup);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(20);

    pointsSlider = cp5.addSlider("points"+getName()).setPosition(0, 55).setSize(395, 45).setRange(4, 20).setNumberOfTickMarks(9).setGroup(controlGroup);
    pointsSlider.getCaptionLabel().set("Edges").align(ControlP5.RIGHT, ControlP5.CENTER);
    pointsSlider.setValue(8);

    rotationSpeedSlider = cp5.addSlider("rotationspeed"+getName()).setPosition(0, 105).setSize(395, 45).setGroup(controlGroup);
    rotationSpeedSlider.setRange(-1, 1).setValue(0.3);
    rotationSpeedSlider.getCaptionLabel().set("Rotation Speed").align(ControlP5.RIGHT, ControlP5.CENTER);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(345, 45).setPosition(50, 155).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);
    HueControlListener hL = new HueControlListener(); 
    hueSlider.addListener(hL);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 155).setSize(45, 45).setGroup(controlGroup);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
  }

  void draw() {

    int points = int(pointsSlider.getValue());
    float weight = weightSlider.getValue();
    float radius = stg.getMinRadius()-weight;
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
    float radius = stg.getMinRadius()/2-1.5*weight;
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
  
 void keyPressed(char key, int keyCode)
  {
    super.keyPressed(key, keyCode);
    if (key == CODED) {
      if (keyCode == LEFT)
        rotationSpeedSlider.setValue(rotationSpeedSlider.getValue()-0.05);
      else if (keyCode == RIGHT)
        rotationSpeedSlider.setValue(rotationSpeedSlider.getValue()+0.05);
    }
  }
}