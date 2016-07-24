class Derby_Effect extends Effect
{
  String getName() {
    return "Derby";
  }
  
  char triggeredByKey() {
    return '5';
  }

  Slider weightSlider, speedSlider, pointSlider, hueSlider;

  Toggle aHueToggle, mirrorToggle;

  float rotation = 0;

  boolean moving = false;

  Derby_Effect(MusicBeam ctrl, int y)
  {
    super(ctrl, y);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(0, 200).setGroup(controlGroup);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(80);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(0, 55).setSize(395, 45).setRange(0, 1).setGroup(controlGroup);
    speedSlider.getCaptionLabel().set("speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(0.5);

    pointSlider = cp5.addSlider("point"+getName()).setPosition(0, 105).setSize(395, 45).setRange(1, 10).setGroup(controlGroup);
    pointSlider.getCaptionLabel().set("points").align(ControlP5.RIGHT, ControlP5.CENTER);
    pointSlider.setValue(4);

    mirrorToggle = cp5.addToggle("mirror"+getName()).setPosition(0, 155).setSize(395, 45).setGroup(controlGroup);
    mirrorToggle.getCaptionLabel().set("Mirror").align(ControlP5.CENTER, ControlP5.CENTER);
    mirrorToggle.setState(true);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(345, 45).setPosition(50, 205).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);
    HueControlListener hL = new HueControlListener(); 
    hueSlider.addListener(hL);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 205).setSize(45, 45).setGroup(controlGroup);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
  }

  void draw()
  {
    float width = stg.width-weightSlider.getValue();
    float height = stg.height-weightSlider.getValue();
    float points = int(pointSlider.getValue());

    translate(-stg.width/2, -stg.height/2);
    stg.fill(hueSlider.getValue(), 100, 100);
    for (int i=1;i<=points;i++)
    {
      stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)+cos(rotation)*width/(points+1), weightSlider.getValue()/2+height/3-height/3*sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
    }
    if (mirrorToggle.getState())
      for (int i=1;i<=points;i++)
      {
        stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)-cos(rotation)*width/(points+1), weightSlider.getValue()/2+height/3-height/3*sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
      }

    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    for (int i=1;i<=points;i++)
    {
      stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)+cos(rotation)*width/(points+1), weightSlider.getValue()/2+2*height/3-height/3*-sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
    }

    if (mirrorToggle.getState())
      for (int i=1;i<=points;i++)
      {
        stg.ellipse(weightSlider.getValue()/2+i*width/(points+1)-cos(rotation)*width/(points+1), weightSlider.getValue()/2+2*height/3-height/3*-sin(rotation), weightSlider.getValue()*0.9, weightSlider.getValue()*0.9);
      }

    if (aHueToggle.getState()&&isOnset())
      hueSlider.setValue((hueSlider.getValue()+120)%360);

    if (rotation%(PI/2)>0.1) {
      moving = false;
      rotation = rotation + speedSlider.getValue()/10%(2*PI);
    }
    else if (rotation%(PI/2)<=0.1 && (isKick() || isSnare() || isOnset() || moving)) {
      moving = true;
      rotation = rotation + speedSlider.getValue()/10%(2*PI);
    } 
    else
    {
      rotation = rotation + getLevel()/100%(2*PI);
      moving = false;
    }
  }
}
