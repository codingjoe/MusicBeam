public class Strobe_Effect extends Effect
{  
  public String getName()
  {
    return "Strobe";
  }

  char triggeredByKey() {
    return '1';
  }

  public Strobe_Effect(MusicBeam controller, int y)
  {

    super(controller, y);

    randomToggle.setState(false);


    manualButton = cp5.addButton("manual"+getName()).setSize(195, 195).setPosition(0, 5).setGroup(controlGroup);
    manualButton.getCaptionLabel().set("Manual Trigger").align(ControlP5.CENTER, ControlP5.CENTER);

    hatToggle = cp5.addToggle("hat"+getName()).setSize(195, 45).setPosition(200, 5).setGroup(controlGroup);
    hatToggle.getCaptionLabel().set("Hat").align(ControlP5.CENTER, ControlP5.CENTER);

    snareToggle = cp5.addToggle("snare"+getName()).setSize(195, 45).setPosition(200, 55).setGroup(controlGroup);
    snareToggle.getCaptionLabel().set("Snare").align(ControlP5.CENTER, ControlP5.CENTER);

    kickToggle = cp5.addToggle("kick"+getName()).setSize(195, 45).setPosition(200, 105).setGroup(controlGroup);
    kickToggle.getCaptionLabel().set("Kick").align(ControlP5.CENTER, ControlP5.CENTER);
    kickToggle.setState(true);

    onsetToggle = cp5.addToggle("onset"+getName()).setSize(195, 45).setPosition(200, 155).setGroup(controlGroup);
    onsetToggle.getCaptionLabel().set("Peak").align(ControlP5.CENTER, ControlP5.CENTER);
    onsetToggle.setState(true);

    delaySlider = cp5.addSlider("delay"+getName()).setRange(10, 30).setValue(28).setPosition(0, 205).setSize(395, 45).setGroup(controlGroup);
    delaySlider.getCaptionLabel().set("Frequency (Hz)").align(ControlP5.RIGHT, ControlP5.CENTER);

    hueSlider = cp5.addSlider("hue"+getName()).setRange(0, 360).setSize(295, 45).setPosition(50, 255).setGroup(controlGroup);
    hueSlider.getCaptionLabel().set("hue").align(ControlP5.RIGHT, ControlP5.CENTER);
    hueSlider.setValue(0);
    HueControlListener hL = new HueControlListener(); 
    hueSlider.addListener(hL);

    aHueToggle = cp5.addToggle("ahue"+getName()).setPosition(0, 255).setSize(45, 45).setGroup(controlGroup);
    aHueToggle.getCaptionLabel().set("A").align(ControlP5.CENTER, ControlP5.CENTER);
    aHueToggle.setState(true);

    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(350, 255).setSize(45, 45).setGroup(controlGroup);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(true);
  }

  boolean state = false;

  float timer = 0;

  Button manualButton;

  Slider delaySlider, hueSlider;

  Toggle hatToggle, snareToggle, kickToggle, onsetToggle, aHueToggle, bwToggle;

  boolean isTriggered()
  {
    if (manualButton.isOn() || effect_manual_triggered)
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

  void draw() {
    if (state && (timer <= 0 || timer < frameRate/2-delaySlider.getValue()-3)) {
      state = false;
      timer = frameRate/2-delaySlider.getValue();
    } 
    else if (!state && isTriggered() && timer <= 0) {
      state = true;
      timer = frameRate/2-delaySlider.getValue();
    }

    if (timer > 0)
      timer--;

    if (aHueToggle.getState())
      hueSlider.setValue((hueSlider.getValue()+1)%360);

    stg.fill(hueSlider.getValue(), bwToggle.getState()?0:100, 100);
    if (state)
      stg.rect(-stg.getMaxRadius()/2, -stg.getMaxRadius()/2, stg.getMaxRadius(), stg.getMaxRadius());
  }

  void keyPressed(char key, int keyCode)
  {
    super.keyPressed(key, keyCode);
    if (key == CODED) {
      if (keyCode == LEFT)
        delaySlider.setValue(delaySlider.getValue()-1);
      else if (keyCode == RIGHT)
        delaySlider.setValue(delaySlider.getValue()+1);
    }
  }
}