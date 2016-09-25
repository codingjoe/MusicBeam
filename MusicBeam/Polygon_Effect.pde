class Polygon_Effect extends Effect
{
  String getName()
  {
    return "Polygon";
  }

  char triggeredByKey() {
    return '8';
  }

  float[] px, py;


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
  
  int points, weight, radius, hue;

  void draw() {

    points = int(pointsSlider.getValue());
    weight = int(weightSlider.getValue());
    hue = int(hueSlider.getValue());

    setEllipse();

    rotate(rotation);
    for (int i=0; i < points; i++) {
      int prev = (i + 1) % points;
      stg.stroke((((i%2)==1?120:0)+hue)%360, 100, 100);
      stg.strokeWeight(weight);
      stg.line(px[i], py[i], px[prev], py[prev]);
      stg.fill(-1);
      stg.noStroke();
      stg.ellipse(px[i], py[i], 1.5*weight, 1.5*weight);
      stg.ellipse(px[prev], py[prev], 1.5*weight, 1.5*weight);
    }
    rotation = (rotation+rotationSpeedSlider.getValue()/20)%(2*PI);

    if (aHueToggle.getState()&& (isKick()&&isSnare()))
      hueSlider.setValue((hue+120)%360);
  }

  // fill up arrays with ellipse coordinate data
  void setEllipse() {
    px = new float[points];
    py = new float[points];
    float radius = stg.getMinRadius()/2-1.5*weight;
    float angle = 360.0/points;
    for ( int i=0; i<points; i++) {
      px[i] = cos(radians(angle))*(radius + weight / 2);
      py[i] = sin(radians(angle))*(radius + weight / 2);  
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