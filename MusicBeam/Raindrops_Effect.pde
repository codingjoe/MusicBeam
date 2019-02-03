class Raindrops_Effect extends Effect
{
  String getName()
  {
    return "Raindrops";
  }

  char triggeredByKey() {
    return 'b';
  }

  Toggle debugToggle,directionToggle;
  Slider fadeSpeedSlider,debugSpeedSlider;
  int tmpCounter;
  int halfWidth = stg.width/2;
  int halfHeight = stg.height/2;
  int dirUP=1;
  int dirDOWN=-1;
  ArrayList<drop> drops = new ArrayList<drop>();
  
  Raindrops_Effect(MusicBeam controller, int y)
  {
    super(controller, y);
    tmpCounter =0;
    stg.noStroke();
    stg.fill(100,0,100);
    stg.ellipseMode(CENTER);
    fadeSpeedSlider = cp5.addSlider("speed"+getName()).setPosition(0, 5).setSize(395, 45).setRange(1, 10).setGroup(controlGroup);
    fadeSpeedSlider.getCaptionLabel().set("Fadespeed").align(ControlP5.RIGHT, ControlP5.CENTER);
    fadeSpeedSlider.setValue(5);
    directionToggle = ctrl.cp5.addToggle("direction"+getName()).setPosition(0, 55).setSize(100, 45).setGroup(controlGroup);
    directionToggle.getCaptionLabel().set("Direction").align(ControlP5.CENTER, ControlP5.CENTER);
    directionToggle.setState(false);
    debugToggle = ctrl.cp5.addToggle("debug"+getName()).setPosition(0, 105).setSize(45, 45).setGroup(controlGroup);
    debugToggle.getCaptionLabel().set("Debug").align(ControlP5.CENTER, ControlP5.CENTER);
    debugToggle.setState(false);
    debugSpeedSlider = cp5.addSlider("debugspeed"+getName()).setPosition(0, 155).setSize(395, 45).setRange(1, 10).setGroup(controlGroup);
    debugSpeedSlider.getCaptionLabel().set("Debugspeed").align(ControlP5.RIGHT, ControlP5.CENTER);
    debugSpeedSlider.setValue(5);
  }

 void draw() {
  if (debugToggle.getState()) {
    if (tmpCounter==0) {
      addDrop();
    }
     tmpCounter+=1;
     if (tmpCounter>=10-debugSpeedSlider.getValue()) {
       tmpCounter=0;
     }
  } else {
    if(isHat()) addDrop();
    if(isSnare()) addDrop();
    if(isKick()) addDrop();
  }
   for (drop dr : drops) {
     dr.update();
     if (dr.size > 0) {
       stg.ellipse(dr.posX, dr.posY, dr.size, dr.size);
     }
   } //<>// //<>//
   for (int i=drops.size()-1; i>=0; i--) {
     drop dr = drops.get(i);
     if (dr.size <=0) {
       drops.remove(i);
     }
   }
  }
  
  class drop {
    int posX, posY, direction;
    float size,targetSize;
    drop(int dir) {
      targetSize=random(10, 100);
      posX=int(random(halfWidth*-1, halfWidth));
      posY=int(random(halfHeight*-1, halfHeight));
      direction=dir;
      size=dir==dirUP?0:targetSize;
      targetSize=dir==dirUP?targetSize:0;
    }
    void update() {
     size += fadeSpeedSlider.getValue()/10*direction;
     if(direction==dirUP && size >= targetSize) {
       direction=dirDOWN;
     }
    }
  }
  
  void addDrop() {
    drops.add(new drop(directionToggle.getState()?dirUP:dirDOWN));
  }
  
/*
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
  */
}
