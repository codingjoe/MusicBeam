class Vortex_Effect extends Effect
{
  String getName()
  {
    return "Vortex";
  }

  char triggeredByKey() {
    return '9';
  }
  Toggle bwToggle, pulseToggle;
  Slider weightSlider, sizeSlider, hueSlider;
  int maxSize, pulseValue, currentPulseValue;
  Vortex_Effect(MusicBeam controller, int y)
  {
    super(controller, y);
    int maxWeight=20; 
    maxSize = min(stg.width, stg.height)-2*maxWeight;
    pulseValue=int(maxSize/20);
    currentPulseValue=0;
    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(1, 20).setGroup(controlGroup);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(8);

    sizeSlider = cp5.addSlider("size"+getName()).setPosition(0, 55).setSize(395, 45).setRange(200, maxSize).setGroup(controlGroup);
    sizeSlider.getCaptionLabel().set("Size").align(ControlP5.RIGHT, ControlP5.CENTER);
    sizeSlider.setValue(maxSize/4*3);

    hueSlider = cp5.addSlider("hue"+getName()).setPosition(0, 105).setSize(345, 45).setRange(0, 360).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(100);

    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(350, 105).setSize(45, 45).setGroup(controlGroup);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(false);

    pulseToggle = ctrl.cp5.addToggle("pulse"+getName()).setPosition(0, 155).setSize(45, 45).setGroup(controlGroup);
    pulseToggle.getCaptionLabel().set("Pulse").align(ControlP5.CENTER, ControlP5.CENTER);
    pulseToggle.setState(false);
  }

  int weight, circleSize, hue;

  void draw() {
    if (pulseToggle.getState()) {
      if (sizeSlider.getMax()==maxSize) {
        sizeSlider.setMax(maxSize-pulseValue);
        if (sizeSlider.getValue() > sizeSlider.getMax()) {
          sizeSlider.setValue(sizeSlider.getMax());
        }
      }
    } else {
      sizeSlider.setMax(maxSize);
    }

    weight = int(weightSlider.getValue());
    circleSize = int(sizeSlider.getValue());
    hue = int(hueSlider.getValue());
    if (pulseToggle.getState()) {
      if (isKick()) {
        currentPulseValue=pulseValue;
      }
      circleSize+=currentPulseValue;
      if (currentPulseValue > 0) {
        currentPulseValue-=1;
      }
    }
    stg.stroke(hueSlider.getValue()%360, bwToggle.getState()?0:100, 100);
    stg.noFill();
    stg.strokeWeight(weight);
    stg.ellipse(0, 0, circleSize, circleSize);
  }

  void keyPressed(char key, int keyCode)
  {
    super.keyPressed(key, keyCode);
    if (key == CODED) {
      if (keyCode == LEFT)
        sizeSlider.setValue(sizeSlider.getValue()-1);
      else if (keyCode == RIGHT)
        sizeSlider.setValue(sizeSlider.getValue()+1);
      else if (keyCode == DOWN)
        weightSlider.setValue(weightSlider.getValue()-1);
      else if (keyCode == UP)
        weightSlider.setValue(weightSlider.getValue()+1);
      else if (keyCode == CONTROL)
        bwToggle.setValue(!bwToggle.getState());
    }
  }
}
