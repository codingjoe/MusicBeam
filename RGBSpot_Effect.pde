class RGBSpot_Effect extends Effect
{
  String getName() {
    return "RGB Spot";
  }

  RGBSpot_Effect(MusicBeam ctrl)
  {
    super(ctrl);

    manualButton = cp5.addButton("manual"+getName()).setSize(85, 95).setPosition(10, 45).moveTo(win);
    manualButton.getCaptionLabel().set("Manual Trigger").align(ControlP5.CENTER, ControlP5.CENTER);

    hatToggle = cp5.addToggle("hat"+getName()).setSize(90, 20).setPosition(100, 45).moveTo(win);
    hatToggle.getCaptionLabel().set("Hat").align(ControlP5.CENTER, ControlP5.CENTER);

    snareToggle = cp5.addToggle("snare"+getName()).setSize(90, 20).setPosition(100, 70).moveTo(win);
    snareToggle.getCaptionLabel().set("Snare").align(ControlP5.CENTER, ControlP5.CENTER);

    kickToggle = cp5.addToggle("kick"+getName()).setSize(90, 20).setPosition(100, 95).moveTo(win);
    kickToggle.getCaptionLabel().set("Kick").align(ControlP5.CENTER, ControlP5.CENTER);
    kickToggle.setState(true);

    onsetToggle = cp5.addToggle("onset"+getName()).setSize(90, 20).setPosition(100, 120).moveTo(win);
    onsetToggle.getCaptionLabel().set("OnSet").align(ControlP5.CENTER, ControlP5.CENTER);
    onsetToggle.setState(true);

    delaySlider = cp5.addSlider("delay"+getName()).setRange(10, stg.refreshRate).setValue(stg.refreshRate/3).setPosition(10, 145).setSize(180, 20).moveTo(win);
    delaySlider.getCaptionLabel().set("delay").align(ControlP5.RIGHT, ControlP5.CENTER);

    radiusSlider = cp5.addSlider("radius"+getName()).setRange(1, 10).setValue(4).setPosition(10, 170).setSize(180, 20).moveTo(win);
    radiusSlider.getCaptionLabel().set("Radius").align(ControlP5.RIGHT, ControlP5.CENTER);
  }

  float[] rx = {
    0
  };

  float[] ry = {
    0
  };

  float rc = 0;

  float timer = 0;

  Button manualButton;

  Toggle hatToggle, snareToggle, kickToggle, onsetToggle;

  Slider delaySlider, radiusSlider;

  float radius = 0;

  void draw()
  {
    radius = stg.minRadius/radiusSlider.getValue();
    translate(-stg.width/2, -stg.height/2);
    stg.fill(60*rc, 100, 10*timer);
    if ((isTriggered()&&timer<=0)) {
      rx[0] = random(radius/2, stg.width-radius/2);
      ry[0] = random(radius/2, stg.height-radius/2);
      rc = random(0, 6);
      timer = delaySlider.getValue();
    }

    stg.ellipse(rx[0], ry[0], radius, radius);
    translate(stg.width, stg.height);
    stg.ellipse(-rx[0], -ry[0], radius, radius);

    if (timer>0)
      timer--;
  }

  boolean isTriggered()
  {
    if (manualButton.isPressed())
      return true;
    else if ((!onsetToggle.getState() && hatToggle.getState() && isHat()) || (onsetToggle.getState() && isOnset() && hatToggle.getState() && isHat()))
      return true;
    else if ((!onsetToggle.getState() && snareToggle.getState() && isSnare()) || (onsetToggle.getState() && isOnset() && snareToggle.getState() && isSnare()))
      return true;
    else if ((!onsetToggle.getState() && kickToggle.getState() && isKick()) || (onsetToggle.getState() && isOnset() && kickToggle.getState() && isKick()))
      return true;
    else if (onsetToggle.getState() && isOnset())
      return true;
    else
      return false;
  }
}

