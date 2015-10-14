import controlP5.*;
import controlP5.Controller;

public abstract class Effect
{

  MusicBeam ctrl;

  Stage stg;

  Group controlGroup;

  Toggle activeToggle, randomToggle, settingsToggle;
  
  Tab settingsTab;
  
  Boolean effect_manual_triggered = false;

  float rotationHistory = 0;

  float[] translationHistory = {
    0, 0
  };

  static final int defaultWidth = 400;

  static final int defaultHeight = 300;
  
  int id;
  
  float frameRate;

  Effect(MusicBeam controller, int i)
  {
    id = i;
    ctrl = controller;
    stg = controller.stage;
    frameRate = stg.frameRate;
    
    int posy = 115+(i*50);

    controlGroup = cp5.addGroup(getName()+"SettingsGroup").hide().setPosition(10,195).setWidth(395).setHeight(30);
    controlGroup.disableCollapse();
    controlGroup.getCaptionLabel().set(getName()+" Settings").align(ControlP5.CENTER, ControlP5.CENTER);
    
    ctrl.activeEffect.addItem("("+triggeredByKey() + ")  " + getName(),i);
    ctrl.activeSetting.addItem("settings"+getName(),i);
    
    randomToggle = cp5.addToggle("random"+getName()).setSize(45, 45).setPosition(670, posy);
    randomToggle.getCaptionLabel().set("RND").align(ControlP5.CENTER, ControlP5.CENTER);
    randomToggle.setState(true);
  }

  abstract String getName();

  abstract void draw();

  void refresh()
  {
    draw();
    resetStage();
  }

  boolean isHat()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdFreq.isHat():false;
  }

  boolean isSnare()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdFreq.isSnare():false;
  }

  boolean isKick()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdFreq.isKick():false;
  }

  boolean isOnset()
  {
    return getLevel()>ctrl.minLevelSlider.getValue()?ctrl.bdSound.isOnset():false;
  }
  
  int getId()
  {
    return id;
  }

  boolean isActive()
  {
    return activeEffect.getState(id);
  }
  
  void activate() {
    activeEffect.activate(id);
    activeSetting.activate(id);
  }
  
  float getLevel()
  {
    return ctrl.in.mix.level();
  }

  void hideControls()
  {
    controlGroup.hide();
  }

  void showControls()
  {
    controlGroup.show();
  }

  void rotate(float r)
  {
    stg.rotate(r);
    rotationHistory+=r;
  }

  void resetRotation()
  {
    stg.rotate(-rotationHistory);
    rotationHistory = 0;
  }

  void translate(float x, float y)
  {
    stg.translate(x, y);
    translationHistory[0]+= x;
    translationHistory[1]+= y;
  }

  void resetTranslation()
  {
    stg.translate(-translationHistory[0], -translationHistory[1]);
    translationHistory[0] = 0;
    translationHistory[1] = 0;
  }
  
  void resetStage()
  {
    resetTranslation();
    resetRotation();
  }
  
  abstract char triggeredByKey();
  
  void keyPressed(char key, int keyCode)
  {
    if (key == 't')
      effect_manual_triggered = true;
  }
  
  void keyReleased(char key, int keyCode)
  {
    if (key == 't')
      effect_manual_triggered = false;
  }
}