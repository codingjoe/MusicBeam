class Raindrops_Effect extends Effect //<>//
{
  String getName()
  {
    return "Raindrops";
  }

  char triggeredByKey() {
    return 'a';
  }

  Toggle interactionToggle, directionToggle, bwToggle;
  Slider fadeSpeedSlider, densitySlider;
  int tmpCounter, maxSize;
  int halfWidth = stg.width/2;
  int halfHeight = stg.height/2;
  int dirUP=1;
  int dirDOWN=-1;
  ArrayList<Drop> drops = new ArrayList<Drop>();

  Raindrops_Effect(MusicBeam controller, int y)
  {
    super(controller, y);
    maxSize = min(stg.width, stg.height);
    tmpCounter = 0;
    stg.noStroke();
    stg.ellipseMode(CENTER);
    fadeSpeedSlider = cp5.addSlider("speed"+getName()).setPosition(105, 5).setSize(290, 45).setRange(1, 10).setGroup(controlGroup);
    fadeSpeedSlider.getCaptionLabel().set("fadespeed").align(ControlP5.RIGHT, ControlP5.CENTER);
    fadeSpeedSlider.setValue(5);
    directionToggle = ctrl.cp5.addToggle("direction"+getName()).setPosition(0, 5).setSize(100, 45).setGroup(controlGroup);
    directionToggle.getCaptionLabel().set("raindrops").align(ControlP5.CENTER, ControlP5.CENTER);
    directionToggle.setState(false);
    interactionToggle = ctrl.cp5.addToggle("interaction"+getName()).setPosition(0, 55).setSize(100, 45).setGroup(controlGroup);
    interactionToggle.getCaptionLabel().set("music").align(ControlP5.CENTER, ControlP5.CENTER);
    interactionToggle.setState(true);
    densitySlider = cp5.addSlider("density"+getName()).setPosition(105, 55).setSize(290, 45).setRange(1, 10).setGroup(controlGroup);
    densitySlider.getCaptionLabel().set("density").align(ControlP5.RIGHT, ControlP5.CENTER);
    densitySlider.setValue(5);
    bwToggle = ctrl.cp5.addToggle("bw"+getName()).setPosition(0, 105).setSize(45, 45).setGroup(controlGroup);
    bwToggle.getCaptionLabel().set("BW").align(ControlP5.CENTER, ControlP5.CENTER);
    bwToggle.setState(true);
  }

  void draw() {
    directionToggle.getCaptionLabel().set(directionToggle.getState() ? "Sunrays" : "Raindrops");
    stg.fill(100, 0, 100);
    if (!interactionToggle.getState()) {
      interactionToggle.getCaptionLabel().set("auto");
      if (tmpCounter==0) {
        addDrop();
      }
      tmpCounter += 1;
      if (tmpCounter >= 10 - densitySlider.getValue()) {
        tmpCounter = 0;
      }
    } else {
      interactionToggle.getCaptionLabel().set("music");
      if (isHat()) addDrop();
      if (isSnare()) addDrop();
      if (isKick()) addDrop();
    }
    for (Drop dr : drops) {
      dr.draw();
    }
    for (int i=drops.size()-1; i>=0; i--) {
      Drop dr = drops.get(i);
      if (dr.size <= 0) {
        drops.remove(i);
      }
    }
  }

  class Drop {
    int posX, posY, direction, hue;
    float size, targetSize;
    
    Drop(int dir) {
      targetSize = random(maxSize / 100, maxSize / 10);
      posX = int(random(halfWidth*-1, halfWidth));
      posY = int(random(halfHeight*-1, halfHeight));
      hue = int(random(0, 360));
      direction = dir;
      size = (dir == dirUP) ? 1: targetSize;
      targetSize = (dir == dirUP) ? targetSize : 1;
      
      bwToggle.getState();
      
    }
    
    void draw() {
      size += fadeSpeedSlider.getValue() * direction / sqrt(size);
      if (direction == dirUP && size >= targetSize) {
       direction = dirDOWN;
     }
     stg.fill(hue % 360, bwToggle.getState() ? 0 : 100, 100);
     if (size > 0) {
       stg.ellipse(posX, posY, size, size);
     }
    }
  }

  void addDrop() {
    drops.add(new Drop(directionToggle.getState() ? dirUP : dirDOWN));
  }
}
