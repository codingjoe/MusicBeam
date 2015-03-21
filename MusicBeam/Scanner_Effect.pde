class Scanner_Effect extends Effect
{ 

  Scanner_Effect(MusicBeam controller, int y)
  {
    super(controller, y);

    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(0, 100).setGroup(controlGroup);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(20);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(0, 55).setSize(395, 45).setRange(0, 1).setGroup(controlGroup);
    speedSlider.getCaptionLabel().set("speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(0.3);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(345, 45).setPosition(50, 105).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 105).setSize(45, 45).setGroup(controlGroup);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);
  }

  public String getName()
  {
    return "Scanner";
  }
  
  char triggeredByKey() {
    return '2';
  }

  float rotation = 0.0f;

  Slider weightSlider, speedSlider, hueSlider;

  Toggle aHueToggle, bwToggle;

  void draw()
  {

    stg.fill(hueSlider.getValue(), 100, 100);

    rotation = (rotation+speedSlider.getValue()/20)%(9*PI);

    if (rotation<PI)
      rotateRight();
    else if (rotation<PI*7/4)
      rotateLeft();
    else if (rotation<PI*3)
      rotateOpposite();
    else if (rotation<PI*4)
      LinesDissolve();
    else if (rotation<PI*5)
      LinesJoin();
    else if (rotation<PI*6)
    {
      rotate(PI/2);
      LinesDissolve();
    } 
    else if (rotation<PI*7)
    {
      rotate(PI/2);
      LinesJoin();
    } 
    else if (rotation<PI*8)
    {
      LinesDissolve();
      resetStage();
      rotate(PI/2);
      stg.fill((hueSlider.getValue()+120)%360, 100, 100);
      LinesDissolve();
    } 
    else if (rotation<PI*9)
    {
      LinesJoin();
      resetStage();
      rotate(PI/2);
      stg.fill((hueSlider.getValue()+120)%360, 100, 100);
      LinesJoin();
    }

    if (aHueToggle.getState() && isKick() && isOnset() && isHat() && isSnare())
      hueSlider.setValue((hueSlider.getValue()+120)%360);
  }

  void rotateRight()
  {
    rotate(rotation);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    rotate(PI/2);
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void rotateLeft()
  {
    rotate(-rotation);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    rotate(-PI/2);
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void rotateOpposite()
  {
    rotate(rotation);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    rotate(-2*rotation);
    stg.fill((hueSlider.getValue()+120)%360, 100, 100);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void LinesDissolve()
  {
    translate(0, (stg.height-weightSlider.getValue())*((rotation%PI)/PI)/2);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    translate(0, -(stg.height-weightSlider.getValue())*(rotation%PI/PI));
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }

  void LinesJoin()
  {
    translate(0, (stg.height-weightSlider.getValue())*(1-((rotation%PI)/PI))/2);
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
    translate(0, -(stg.height-weightSlider.getValue())*(1-((rotation%PI)/PI)));
    stg.rect(-stg.maxRadius/2, -weightSlider.getValue()/2, stg.maxRadius, weightSlider.getValue());
  }
}

