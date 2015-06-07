class RGBLine_Effect extends Effect
{
  String getName() {
    return "RGB Line";
  }
  
  char triggeredByKey() {
    return '0';
  }
  

  LinkedList<Float[]> history;

  RGBLine_Effect(MusicBeam ctrl, int y)
  {
    super(ctrl, y);

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

    delaySlider = cp5.addSlider("delay"+getName()).setRange(0.01,1).setValue(0.3).setPosition(0, 205).setSize(395, 45).setGroup(controlGroup);
    delaySlider.getCaptionLabel().set("Speed").align(ControlP5.RIGHT, ControlP5.CENTER);

    radiusSlider = cp5.addSlider("radius"+getName()).setRange(0, 1).setValue(0.85).setPosition(0, 255).setSize(395, 45).setGroup(controlGroup);
    radiusSlider.getCaptionLabel().set("Radius").align(ControlP5.RIGHT, ControlP5.CENTER);
    
    history = new LinkedList<Float[]>();

  }

  Button manualButton;

  Toggle hatToggle, snareToggle, kickToggle, onsetToggle;

  Slider delaySlider, radiusSlider;

  int elements = 200;
  int ecount = 0;
  int x1 = -stg.width/2-stg.height/2;
  int y1 = 0;
  int x2 = stg.width/2+stg.height/2;
  int y2 = 0;
  float g = 0;
  float gR = 0;
  int gx1 = 0;
  int gy1 = 0;
  int gx2 = 0;
  int gy2 = 0;
  void draw()
  {
    translate(0, 0);
    Float dat[]={FrequencyColor[0], FrequencyColor[1], FrequencyColor[2]};
    history.add(dat);
    if(ecount<elements)ecount++;
    if(history.size()>elements)history.removeFirst();
    stg.strokeWeight(radiusSlider.getValue()*30);
    
    if(ctrl.isKick()){
    gx1=int(random(-stg.width/2, stg.width/2));
    gx2=int(random(-stg.width/2, stg.width/2));
    gy1=int(random(-stg.height/2, stg.height/2));
    gy2=int(random(-stg.height/2, stg.height/2));
    }
    x1*=10;
    x1+=gx1;
    x1/=11;
    x2*=10;
    x2+=gx2;
    x2/=11;
    y1*=10;
    y1+=gy1;
    y1/=11;
    y2*=10;
    y2+=gy2;
    y2/=11;
    
    int xs = (x2-x1)/elements;
    int ys = (y2-y1)/elements;
    
    for(int i=0;i<ecount;i++){
     Float c[] = history.get(i);
     stg.stroke(c[0], c[1], c[2]);
     stg.line(x1+xs*i,y1+ys*i,x1+xs*(i+1),y1+ys*(i+1));
    }
  
  }

}

