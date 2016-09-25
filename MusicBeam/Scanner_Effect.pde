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
    HueControlListener hL = new HueControlListener(); 
    hueSlider.addListener(hL);

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

  int hue, weight;
  float speed;

  void draw()
  {

    hue = int(hueSlider.getValue());
    weight = int(weightSlider.getValue());
    speed = speedSlider.getValue();

    stg.stroke(hue, 100, 100);
    stg.strokeWeight(weight);

    rotation = (rotation+speed/20)%(9*PI);

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
    } else if (rotation<PI*7)
    {
      rotate(PI/2);
      LinesJoin();
    } else if (rotation<PI*8)
    {
      LinesDissolve();
      resetStage();
      rotate(PI/2);
      stg.fill((hue+120)%360, 100, 100);
      LinesDissolve();
    } else if (rotation<PI*9)
    {
      LinesJoin();
      resetStage();
      rotate(PI/2);
      stg.fill((hue+120)%360, 100, 100);
      LinesJoin();
    }

    if (aHueToggle.getState() && isKick() && isOnset() && isHat() && isSnare())
      hueSlider.setValue((hue+120)%360);
  }

  void rotateRight()
  {
    rotate(rotation);
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
    stg.stroke((hue+120)%360, 100, 100);
    stg.line(0, -stg.getMaxRadius(), 0, stg.getMaxRadius());
  }

  void rotateLeft()
  {
    rotate(-rotation);
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
    stg.stroke((hue+120)%360, 100, 100);
    stg.line(0, -stg.getMaxRadius(), 0, stg.getMaxRadius());
    stg.stroke(hue, 100, 100);
  }

  void rotateOpposite()
  {
    rotate(rotation);
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
    stg.stroke((hue+120)%360, 100, 100);
    stg.line(0, -stg.getMaxRadius(), 0, stg.getMaxRadius());
    stg.stroke(hue, 100, 100);
  }

  void LinesDissolve()
  {
    translate(0, (stg.height-weight)*((rotation%PI)/PI)/2);
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
    translate(0, -(stg.height-weight)*(rotation%PI/PI));
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
  }

  void LinesJoin()
  {
    translate(0, (stg.height-weight)*(1-((rotation%PI)/PI))/2);
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
    translate(0, -(stg.height-weight)*(1-((rotation%PI)/PI)));
    stg.stroke((hue+120)%360, 100, 100);
    stg.line(-stg.getMaxRadius(), 0, stg.getMaxRadius(), 0);
  }
}