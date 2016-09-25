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
  
  int weight, points, hue;
  float speed;

  void draw()
  {
    weight = int(weightSlider.getValue());
    points = int(pointSlider.getValue());
    hue = int(hueSlider.getValue());
    speed = speedSlider.getValue();
    
    float width = stg.width-weight;
    float height = stg.height-weight;
    
    int countTrigger = 0;
    if(isHat()) countTrigger++;
    if(isSnare()) countTrigger++;
    if(isKick()) countTrigger++;

    translate(-stg.width/2, -stg.height/2);
    
    for (int i=1;i<=points;i++)
    {
      float posx = weight/2+i * width/(points+1);
      float rotx = width/(points+1) * cos(rotation);
      float posy = weight/2+height/3;
      float roty = -height/3 * sin(rotation);
      
      stg.fill(hue, 100, 100);
      
      stg.ellipse(posx+rotx, posy+roty, weight*0.9, weight*0.9);
      
      if (mirrorToggle.getState())
        stg.ellipse(posx-rotx, posy+roty, weight*0.9, weight*0.9);
        
      stg.fill((hue+120)%360, 100, 100);
        
      stg.ellipse(posx+rotx, height/3 + posy-roty, weight*0.9, weight*0.9);
      
      if (mirrorToggle.getState())
        stg.ellipse(posx-rotx, height/3 + posy-roty, weight*0.9, weight*0.9);
        
    }

    if (aHueToggle.getState() && countTrigger >= 2)
      hueSlider.setValue((hue+120)%360);

    if (rotation%(PI/2)>0.1) {
      moving = false;
      rotation = rotation + speed/10%(2*PI);
    }
    else if (rotation%(PI/2)<=0.1 && (isKick() || isSnare() || isOnset() || moving)) {
      moving = true;
      rotation = rotation + speed/10%(2*PI);
    } 
    else
    {
      rotation = rotation + getLevel()/100%(2*PI);
      moving = false;
    }
  }
}