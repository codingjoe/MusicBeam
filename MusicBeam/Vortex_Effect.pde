class Vortex_Effect extends Effect
{
  String getName()
  {
    return "Spinner";
  }

  char triggeredByKey() {
    return '9';
  }
  int currentPulseValue, maxSize;
  float offset, gap;
  boolean swap;
  Toggle bwToggle, dualColourToggle, swapColourToggle, pulseToggle;
  Slider weightSlider, sizeSlider, gapSlider, hueSlider, hue2Slider, speedSlider;

  Vortex_Effect(MusicBeam controller, int y)
  {
    super(controller, y);
    swap=false;
    int maxWeight =20;
    maxSize = min(stg.width, stg.height) - maxWeight;
    currentPulseValue=0;
    weightSlider = cp5.addSlider("weight"+getName()).setPosition(0, 5).setSize(395, 45).setRange(1, 100).setGroup(controlGroup);
    weightSlider.getCaptionLabel().set("Weight").align(ControlP5.RIGHT, ControlP5.CENTER);
    weightSlider.setValue(20);

    sizeSlider = cp5.addSlider("size"+getName()).setPosition(0, 55).setSize(395, 45).setRange(200, maxSize).setGroup(controlGroup);
    sizeSlider.getCaptionLabel().set("Size").align(ControlP5.RIGHT, ControlP5.CENTER);
    sizeSlider.setValue(maxSize/4*3);

    speedSlider = cp5.addSlider("speed"+getName()).setPosition(0, 105).setSize(395, 45).setRange(-45, 45).setGroup(controlGroup);
    speedSlider.getCaptionLabel().set("Speed").align(ControlP5.RIGHT, ControlP5.CENTER);
    speedSlider.setValue(7.5);

    gapSlider = cp5.addSlider("gap"+getName()).setPosition(0, 155).setSize(395, 45).setRange(0, 180).setGroup(controlGroup);
    gapSlider.getCaptionLabel().set("gap").align(ControlP5.RIGHT, ControlP5.CENTER);
    gapSlider.setValue(90);

    hueSlider = cp5.addSlider("hue"+getName()).setPosition(0, 205).setSize(395, 45).setRange(0, 360).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(50);

    hue2Slider = cp5.addSlider("hue2"+getName()).setPosition(0, 255).setSize(395, 45).setRange(0, 360).setGroup(controlGroup);
    hue2Slider.getCaptionLabel().set("hue2").align(ControlP5.RIGHT, ControlP5.CENTER);
    hue2Slider.setValue(300);

    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(0, 305).setSize(45, 45).setGroup(controlGroup);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(false);

    dualColourToggle = ctrl.cp5.addToggle("link"+getName()).setPosition(50, 305).setSize(110, 45).setGroup(controlGroup);
    dualColourToggle.getCaptionLabel().set("Dual Colours").align(ControlP5.CENTER, ControlP5.CENTER);
    dualColourToggle.setState(true);

    swapColourToggle = ctrl.cp5.addToggle("swapclolour"+getName()).setPosition(165, 305).setSize(110, 45).setGroup(controlGroup);
    swapColourToggle.getCaptionLabel().set("Swap Colours").align(ControlP5.CENTER, ControlP5.CENTER);
    swapColourToggle.setState(false);
    
    pulseToggle = ctrl.cp5.addToggle("pulse"+getName()).setPosition(280, 305).setSize(115, 45).setGroup(controlGroup);
    pulseToggle.getCaptionLabel().set("pulse").align(ControlP5.CENTER, ControlP5.CENTER);
    pulseToggle.setState(false);
  }

  int weight, circleSize, hue, hue2;

  void draw() {
    stg.noFill();
    stg.strokeWeight(weight);
    offset += speedSlider.getValue();
    offset = getDegree(offset);
    gap = 180 - gapSlider.getValue();
    weight = int(weightSlider.getValue());
    circleSize = int(sizeSlider.getValue());
    hue = int(hueSlider.getValue());
    hue2 = int(dualColourToggle.getState()?hue2Slider.getValue():hue);

    if (isKick()) {
      currentPulseValue = maxSize - circleSize;
    }
    if (currentPulseValue > 0) {
      currentPulseValue -= sqrt(currentPulseValue);
    }

    if (pulseToggle.getState()) {
      circleSize += currentPulseValue;
    }


    if (dualColourToggle.getState() && swapColourToggle.getState()) {
      if (isHat()) {
        swap=!swap;
      }
      if (swap) {
        int tmp=hue;
        hue=hue2;
        hue2=tmp;
      }
    }

    stg.stroke(hue%360, bwToggle.getState()?0:100, 100);
    stg.arc(0, 0, circleSize, circleSize, radians(offset), radians(getDegree(offset+gap)));
    stg.stroke(hue2%360, bwToggle.getState()?0:100, 100);
    stg.arc(0, 0, circleSize, circleSize, radians(getDegree(offset + 180)), radians(getDegree(offset + gap + 180)));
  }

  void keyPressed(char key, int keyCode)
  {
    super.keyPressed(key, keyCode);
    if (key == CODED) {
      if (keyCode == LEFT)
        sizeSlider.setValue(sizeSlider.getValue() - maxSize/20);
      else if (keyCode == RIGHT)
        sizeSlider.setValue(sizeSlider.getValue() + maxSize/20);
      else if (keyCode == DOWN)
        speedSlider.setValue(speedSlider.getValue()-1);
      else if (keyCode == UP)
        speedSlider.setValue(speedSlider.getValue()+1);
      else if (keyCode == CONTROL)
        bwToggle.setValue(!bwToggle.getState());
    }
  }
  float getDegree(float in) {
    if (in<0) {
      return in+360;
    }
    if (offset>=360) {
      return in-360;
    }
    return in;
  }
}
