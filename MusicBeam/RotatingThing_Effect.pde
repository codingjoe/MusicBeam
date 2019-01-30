class RotatingThing_Effect extends Effect
{
  String getName()
  {
    return "RotatingThing";
  }

  char triggeredByKey() {
    return 'a';
  }
  float offset;
  Toggle bwToggle;
  Slider weightSlider, radiusSlider, hueSlider, speedSlider;

  RotatingThing_Effect(MusicBeam controller, int y)
  {
    super(controller, y);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(1, 20).setGroup(controlGroup);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(8);

    radiusSlider = cp5.addSlider("radius"+getName()).setPosition(0, 55).setSize(395, 45).setRange(200, 1000).setGroup(controlGroup);
    radiusSlider.getCaptionLabel().set("Radius").align(ControlP5.RIGHT, ControlP5.CENTER);
    radiusSlider.setValue(600);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(0, 105).setSize(395, 45).setRange(-180, 180).setGroup(controlGroup);
    speedSlider.getCaptionLabel().set("Speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(10);

    hueSlider = cp5.addSlider("hue"+getName()).setPosition(0, 155).setSize(345, 45).setRange(0, 360).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(100);
    
    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(350, 155).setSize(45, 45).setGroup(controlGroup);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(false);
  }
  
  int points, weight, radius, hue;

  void draw() {
    offset+=speedSlider.getValue();
    offset=getDegree(offset);
    weight = int(weightSlider.getValue());
    radius = int(radiusSlider.getValue());
    hue = int(hueSlider.getValue());
    stg.stroke(hueSlider.getValue()%360, bwToggle.getState()?0:100, 100);
    stg.noFill();
    stg.strokeWeight(weight);
    stg.arc(0, 0, radius, radius, radians(offset),radians(getDegree(offset+90)));
    stg.arc(0, 0, radius, radius, radians(getDegree(offset+180)),radians(getDegree(offset+270)));
  }

  void keyPressed(char key, int keyCode)
  {
    super.keyPressed(key, keyCode);
    if (key == CODED) {
      if (keyCode == LEFT)
        radiusSlider.setValue(radiusSlider.getValue()-1);
      else if (keyCode == RIGHT)
        radiusSlider.setValue(radiusSlider.getValue()+1);
      else if (keyCode == DOWN)
        speedSlider.setValue(speedSlider.getValue()-1);
      else if (keyCode == UP)
        speedSlider.setValue(speedSlider.getValue()+1);
      else if (keyCode == CONTROL)
        bwToggle.setValue(!bwToggle.getState());
    }
  }
  float getDegree(float in) {
    if(in<0) {
      return in+360;
    }
    if(offset>=360) {
      return in-360;
    }
    return in;
  }
}
