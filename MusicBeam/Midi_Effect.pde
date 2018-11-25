import java.util.Iterator;
import java.lang.reflect.Method;
import java.lang.reflect.Constructor;

class Midi_Effect extends Effect
{ 
  JSONObject jsonconfig;
  JSONObject fxconfig;
  JSONObject curveconfig;

  Midi_Effect(MusicBeam controller, int y)
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
    
    addLineUp = cp5.addButton("LnUp"+getName()).setSize(45, 45).setPosition(0, 155).setGroup(controlGroup);
    addLineUp.getCaptionLabel().set("LnUp").align(ControlP5.CENTER, ControlP5.CENTER);

    addLineDown = cp5.addButton("LnDown"+getName()).setSize(45, 45).setPosition(50, 155).setGroup(controlGroup);
    addLineDown.getCaptionLabel().set("LnDown").align(ControlP5.CENTER, ControlP5.CENTER);
    
    reloadConfigButton = cp5.addButton("reloadConfig").setSize(195, 95).setPosition(0, 205).setGroup(controlGroup).setValue(0);
    reloadConfigButton.getCaptionLabel().set("Reload config").align(ControlP5.CENTER, ControlP5.CENTER);

    
    fxBuffer.add(new ScreenFx());
    
    reloadConfig();
  }

  Button reloadConfigButton;
  
  public void controlEvent(ControlEvent theEvent) {
    println(theEvent.getController().getName());
  }

  public void reloadConfig() {
    println("Reloading config");
    try {
      jsonconfig = loadJSONObject("fxconfig.json");
      fxconfig = jsonconfig.getJSONObject("fx");
      curveconfig = jsonconfig.getJSONObject("curves");
    } catch(Exception ex) {
      ex.printStackTrace();
    }
  }
  
  public String getName()
  {
    return "Midi";
  }

  char triggeredByKey() {
    return '0';
  }

  float rotation = 0.0f;

  Slider weightSlider, speedSlider, hueSlider;

  Toggle aHueToggle, bwToggle;
  Button addLineUp;
  Button addLineDown;

  int hue, weight;
  float speed;
  
  public LinkedList fxBuffer = new LinkedList();
    
  void draw()
  {
     //if (reloadConfigButton.isOn()) {
     //  reloadConfigButton.setOff();
     //  reloadConfig();
     //}

    //println("rotation: "+ (rotation / PI));
    hue = int(hueSlider.getValue());
    weight = int(weightSlider.getValue());
    speed = speedSlider.getValue();

    stg.stroke(hue, 100, 100);
    stg.strokeWeight(weight);
    stg.noFill();

    rotation = (rotation+speed);
    

    for(int i=0; i<fxBuffer.size(); i++) {
      Fx fx = (Fx)fxBuffer.get(i);
      fx.framerate(stg.frameRate);
      if(fx.remove) {
        // println("removing " + fx);
        fxBuffer.remove(i);
      } else {
        fx.applyMod().draw();
      }
    }

     resetStage();


    if (aHueToggle.getState() && isKick() && isOnset() && isHat() && isSnare())
      hueSlider.setValue((hue+120)%360);
  }

  float rate = frameRate;  
        
  class CirclePumpFx extends Fx {
    public CirclePumpFx() {}
    public void draw() {
      super.draw();
      int pos = Math.round(2*stg.height*this.rotation);
      stg.stroke(hue, 100, 100);
      stg.strokeWeight(weight);
      stg.fill(0);
      float r = 200+400*sin(this.rotation/8);
      stg.ellipse(sin(this.rotation*PI)*500,sin(this.rotation*PI/2),r,r);
      if(this.rotation >= 2 ) this.remove = true;
    }
  }
  
  class CirclePumpOutFx extends Fx {
    public CirclePumpOutFx() {}
    public void draw() {
      super.draw();
      stg.stroke(hue, 100, 100);
      stg.strokeWeight(weight);
      stg.fill(0);
      float r = 100+stg.getMaxRadius()*sin(this.rotation/2);
      stg.ellipse(0,0,r,r);
      if(this.rotation >= 2 ) this.remove = true;
    }
  }

  class WaveFx extends Fx {
    public WaveFx() {
    }
    public void draw() {
      super.draw();
      stg.stroke(hue, 100, 100);
      stg.strokeWeight(weight);
      stg.fill(0);
      float r = 400*sin(this.rotation*4);

      float h = 300;
      float w = stg.width/2;
      float x = w/6;
      stg.ellipse(-x,r+h,100,100);
      stg.ellipse(x,h-r,100,100);

      stg.bezier(
        -w,h,
        -x,r+h,
        x,h-r,
        w,0+h
       );
      if(this.rotation >= 24 ) this.remove = true;
    }
  }

  class WaveFlowFx extends Fx {
    public WaveFlowFx() {
    }
    public void draw() {
      super.draw();
      stg.stroke(hue, 100, 100);
      stg.strokeWeight(weight);
      stg.fill(0);
      float r = 300;//*sin(this.rotation*4);

      float h = 300+50*sin(this.rotation*6);
      float w = stg.width/2;//+stg.width*1/3;
      float x = w/3;//stg.width*1/3;
      float wd = x*this.rotation%(x/20*rate);
      
      stg.ellipse(wd,h+200,100,100);
      //stg.ellipse(x,h-r,100,100);

      stg.bezier(
        -w+wd,h,
        -w+x+wd, h+r,
        -w+x+x+wd, h-r,
        0+wd,0+h
      );
      stg.bezier(
        w+wd,h,
        w-x+wd, h-r,
        w-x-x+wd, h+r,
        0+wd,0+h
       );
      stg.bezier(
        -w-w+wd,h,
        -w-w+x+wd, h+r,
        -w-w+x+x+wd, h-r,
        -w-0+wd,0+h
       );
      if(this.rotation >= 24 ) this.remove = true;
    }
  }

  class ScreenFx extends Fx {
    public ScreenFx() {}
    public void draw() {
      super.draw();
      stg.stroke(hue, 100, 100);
      stg.strokeWeight(weight);
      stg.noFill();

      float h = 300+50*sin(this.rotation*6);
      float w = stg.width/2;//+stg.width*1/3;
      float x = w/3;//stg.width*1/3;
      float wd = x*this.rotation%(x/20*rate);
      float wi = stg.width;
      float hi = stg.height;
      
      float s = sin(this.rotation);
      float s1 = sin(this.rotation);
      float s2 = sin(this.rotation*2);
      float s3 = sin(this.rotation*3);
      float s4 = sin(this.rotation*4);
      float s5 = sin(this.rotation*5);
      
      float xmv1 = wi/3*s1;
      float xmv2 = wi/3*s2;
      float xmv3 = wi/3*s3;
      float xmv4 = wi/3*s4;
      float xmv5 = wi/3*s5;
      
      stg.stroke(hue, 100, 100);
      
      float[] coords = {-wi/2,0, -wi/2,0, -xmv1,s5*hi/3, 0+xmv4,-s2*hi/5, xmv3,s1*-hi/2, wi/2,0, wi/2,0};
      stg.smooth();
      stg.beginShape();
      for(int i=0; i<coords.length; i += 2) {
        stg.curveVertex(coords[i], coords[i+1]); 
      }
      stg.endShape();

      //stg.stroke(100, 100, 100);
      //for(int i=0; i<coords.length; i += 2) {
      //  stg.ellipse(coords[i], coords[i+1], 30, 30);
      //}
      
      if(this.rotation >= 5 ) this.remove = true;
    }
  }
  
  class SnowStormFx extends Fx {
    public SnowStormFx() {
      calcPoints();
    };
    LinkedList<Float> lr, lx, ly;

    int px, py, pts;

    int lauf = 0;
    float radiusSliderValue = 80; // 50-200
    int hueSliderValue = 0; // 0-360
    boolean bwToggleState = true;
  
    void draw()
    {
      translate(-stg.width/2-lauf*speedSlider.getValue()*10, -stg.height/2);
      for (int i=0;i<pts;i++) {
        float posx, posy;
        posx = (2*radiusSliderValue*(i%px))+lx.get(i);
        posy = (2*radiusSliderValue*(i/px))+ly.get(i);
        stg.fill(hueSliderValue%360, bwToggleState?0:100, 100);
        stg.stroke(0);
        stg.ellipse(posx, posy, lr.get(i), lr.get(i));
      }
  
      if (lauf>=(2*radiusSliderValue/(speedSlider.getValue()*10))-1) {  
        lx.add(lx.remove());
        ly.add(ly.remove());
        lr.add(lr.remove());
        lauf=0;
      } 
      else
        lauf++;
  
      if (aHueToggle.getState()&& (isKick()&&isSnare()))
        hueSlider.setValue((hueSlider.getValue()+60)%360);
    }
  
    void calcPoints() {
      px = int(stg.width/(2*radiusSliderValue))+2;
      py = int(stg.height/(2*radiusSliderValue))+1;
      pts = px*py;
      lx = new LinkedList();
      ly = new LinkedList();
      lr = new LinkedList();
      for (int i=0;i<pts;i++) {
        lr.add(i, random(radiusSliderValue/10, radiusSliderValue));
        lx.add(i, random(0, radiusSliderValue));
        ly.add(i, random(0, radiusSliderValue));
      }
    }
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
  
  String LINE_GOBO = "LINE_GOBO"; 
  String TRIANGEL_GOBO = "TRIANGEL_GOBO"; 
  String SQUARE_GOBO = "SQUARE_GOBO"; 
  String CIRCLE_GOBO = "CIRCLE_GOBO"; 
  String PARABOLA_GOBO = "PARABOLA_GOBO";
  
  public class DotGobo extends CurveGobo {

    public DotGobo() {
    }
    
    public void draw() {
      // super.draw();
      for(int i=0; i<this.curve.length; i += 2) {
        this.addPoint(this.curve[i]/100, this.curve[i+1]/100);
        //stg.fill((hueSlider.getValue())%360, fxbw?0:100, 100);
        stg.ellipse(this.pointX, this.pointY, weightSlider.getValue(), weightSlider.getValue());
      }
    }      
  }
  
  public class CurveGobo extends Gobo {
    public float[] curve = null;
    public float pointX = 0;
    public float pointY = 0;

    public CurveGobo() {
    }
        
    public CurveGobo curve(String gobo) {
      JSONArray a = curveconfig.getJSONArray(gobo);
      this.curve = a.getFloatArray();
      return this;
    }
    public void draw() {
      super.draw();
      stg.beginShape();
      for(int i=0; i<this.curve.length; i += 2) {
        this.addPoint(this.curve[i]/100, this.curve[i+1]/100);
        if(this.smooth) stg.curveVertex(
          this.pointX, 
          this.pointY
        );
        else stg.vertex(
          this.pointX, 
          this.pointY
        );
      }
      stg.endShape();
    }
    
    public void addPoint(float x, float y) {
        float xrot = x*cos(this.angle*PI) - y*sin(this.angle*PI);
        float yrot= x*sin(this.angle*PI) + y*cos(this.angle*PI);
        //float xrot = x*cos(this.angle*PI/2) - y*sin(this.angle*PI/2);
        //float yrot= x*sin(this.angle*PI/2) + y*cos(this.angle*PI/2);
        float h = stage.height/2;
        this.pointX = (this.x  * h) + (this.scale * (xrot) * this.goboSize * stage.height); 
        this.pointY = (this.y  * h) + (this.scale * (yrot) * this.goboSize * stage.height);
    }
  }

  
  void keyPressed(char key, int keyCode)
  {
    super.keyPressed(key, keyCode);
    println("keyPressed: key: "+key+" keyCode: "+keyCode);
    if (keyCode == 192) {
      reloadConfig();
    }
    for (Iterator<String> it = fxconfig.keyIterator(); it.hasNext(); ) {
      JSONObject o = fxconfig.getJSONObject(it.next());
      if(keyCode == o.getInt("keyCode")) {
        fxBuffer.add(createObject(o.getJSONObject("FX")));
      }
    }
    
    if (key == CODED) {
      if (keyCode == LEFT) {
        fxBuffer.add(
          (new GoboFx())
            .gobo( 
              (new CurveGobo())
                .curve(PARABOLA_GOBO).smooth()
            )
          .duration(2)
          .start(0,0,0,1)
          .end(0,0,2,2)
        );
      } else if (keyCode == RIGHT) {
        // fxBuffer.add(new LineDownFx());
        fxBuffer.add(
          (new GoboFx()).gobo(
            (new CurveGobo()).curve(LINE_GOBO).gobosize(1/7).smooth()
          )
          .duration(4)
          .start(-0.5,-0.5,0,1)
          .end(1,1,-1,7)
        );
      } else if (keyCode == 119) {
        fxBuffer.add(new CirclePumpFx());
      } else if (keyCode == DOWN) {
        fxBuffer.add(
          (new GoboFx()).gobo(
            (new CurveGobo()).curve(CIRCLE_GOBO).gobosize(1/7).nosmooth()
          )
          .duration(4)
          .start(0,0,0,1)
          .end(0,0,0.5,7)
        );
      } else if (keyCode == UP) {
        Mod mod = new ModRotate();
        try {
          Class classRef = Class.forName("Mod");
          mod = (Mod)classRef.newInstance();
        } catch(Exception e) {}
        
        fxBuffer.add(
          (new GoboFx()).gobo(
            (new CurveGobo()).curve(CIRCLE_GOBO).gobosize(1/50).smooth()
          )
          .duration(2)
          .addMod(mod)
          .start(0,0,0,1)
          //.end(0.5,0.5,0,1)
          .end(1-random(1),1-random(1),0,2)
        );
      }
    }
  }

  /*
  {
    "midinote": 48,
    "keyCode": 65,
    "FX": {
      "GoboFx": {
        "gobo": {
          "CurveGobo": {
            "curve": "CIRCLE_GOBO",
            "gobosize": 0.02,
            "smooth": null
          }
        },
        "duration": 2,
        "addMod": {"Mod": null}
        "start": [0,0,0,1],
        "end": [0.5,0.5,0,1] 
      }
    }
  }
  */
  Object createObject(JSONObject o) {
    Object obj = null;
    try {
      
      String className = (String)o.keyIterator().next();
      if (className!=null) {
        // println("class: "+className);
        Class c = Class.forName(this.getClass().getName()+"$"+className);
        if(className.startsWith("MusicBeam$Midi_Effect")) {
          Constructor constructor = c.getConstructor(Midi_Effect.class);
          obj = constructor.newInstance(this);
        } else if(className.startsWith("MusicBeam")) {
          Constructor constructor = c.getConstructor(MusicBeam.class);
          obj = constructor.newInstance(musicBeam);
        } else {
          Constructor constructor = c.getConstructor(Midi_Effect.class);
          obj = constructor.newInstance(this);
        }
        
        
        JSONObject params = o.getJSONObject(className);
        for (Iterator<String> it = params.keyIterator(); it.hasNext(); ) {
          String param = it.next();
          Object val = params.get(param);
          if (val!=null && !params.isNull(param)) {
            // println("PARAM: "+param+" = "+val);
            if(val instanceof JSONObject) {
              val = createObject((JSONObject)val);
            } else if(val instanceof JSONArray) {
              val = ((JSONArray)val).getFloatArray();
            } else if(val instanceof Number) {
              val = params.getFloat(param);
            } else {
              val = params.getString(param);
            }
            try {
              Class[] cArg;
              if(val.getClass().isArray()) {
                int ln = ((float[])val).length;
                cArg = new Class[4];
                for(int i=0; i<4; i++) cArg[i] = float.class;
                Method method = c.getMethod(param, float.class, float.class, float.class, float.class);
                float[] valarr = (float[])val;
                method.invoke(obj, valarr[0], valarr[1], valarr[2], valarr[3]);
              } else {
                cArg = new Class[1];
                cArg[0] = (val instanceof Number)?float.class:val.getClass();
                                
                if (val.getClass().getName().equals("MusicBeam$Midi_Effect$CurveGobo") 
                    || val.getClass().getName().equals("MusicBeam$Midi_Effect$DotGobo")) {
                  cArg[0]=Gobo.class;
                }
                Method method = c.getMethod(param, cArg);
                method.invoke(obj, val);
              }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
          } else {
            try {
              Method method = c.getMethod(param);
              method.invoke(obj);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
          }
        }
      }
      
    } catch(Exception e) {
      e.printStackTrace();
    }
    return obj;
  }
  
  void midiMessage(MidiMessage message, long timestamp, String bus_name) {
    // 144 - note, 176 = CC
    int msg = (int)(message.getMessage()[0] & 0xFF) ;
    int note = (int)(message.getMessage()[1] & 0xFF) ;
    int vel = (int)(message.getMessage()[2] & 0xFF);
    
    if (msg==144) { // Note on
      for (Iterator<String> it = fxconfig.keyIterator(); it.hasNext(); ) {
        JSONObject o = fxconfig.getJSONObject(it.next());
        if(note == o.getInt("midinote")) {
          fxBuffer.add(createObject(o.getJSONObject("FX")));
        }
      }
    }

  }
  abstract class Mod {
    public float x = 1;
    public float y = 1;
    public float scaleX = 1;
    public float scaleY = 1;
    public Mod() {}
    abstract public Fx mod(Fx fx); 
  }
  class ModRotate extends Mod {
    public ModRotate() {
    }
    public ModRotate(float x, float y, float scaleX, float scaleY) {
      this.x = x;
      this.y = y;
      this.scaleX=scaleX;
      this.scaleY=scaleY;
    }
    public Fx mod(Fx fx) {
      float r = fx.rotation*2*PI/fx.duration;
      fx.x = fx.x*this.scaleX*cos(r*this.x);
      fx.y = fx.y*this.scaleY*sin(r*this.y);
      return fx;
    }
  }
  class ModRandom extends Mod {
    public ModRandom() {
    }
    public ModRandom(float x, float y, float scaleX, float scaleY) {
      this.x = x/2-random(x);
      this.y = y/2-random(y);
      this.scaleX=1+random(scaleX);
      this.scaleY=1+random(scaleY);
    }
    public Fx mod(Fx fx) {
      //float r = fx.rotation*2*PI/fx.duration;
      fx.x = fx.x*this.scaleX+this.x;
      fx.y = fx.y*this.scaleY+this.y;
      return fx;
    }
  }
  class Fx {
    float x = 0;
    float y = 0;
    float scale = 1;
    float angle = 0;
    
    float startx = x;
    float starty = y;
    float startscale = scale;
    float startangle = angle;

    float finalx = startx;
    float finaly = starty;
    float finalscale = startscale;
    float finalangle = startangle;

    float fxhue = hue;
    float fxbw = 100;
    float fillHue = 0;
    float fillBw = -1;
    
    float rotation = 0;
    float bpm = 120;
    float framerate = 30;
    float duration = 1;
    float loop = duration;
    boolean remove = false;
    
    public LinkedList modificators = new LinkedList();
    
    public Fx() {
    }
    
    public Fx addMod(Mod mod) {
      modificators.push(mod);
      return this;
    }
    public Fx modRotate(float x, float y, float scaleX, float scaleY) {
      this.addMod(new ModRotate(x,y,scaleX,scaleY));
      return this;
    }
    public Fx modRandom(float x, float y, float scaleX, float scaleY) {
      this.addMod(new ModRandom(x,y,scaleX,scaleY));
      return this;
    }
    
    public Fx applyMod() {
      this.rotation = this.rotation+getStep();
      if(this.rotation >= this.duration) this.remove = true;
            
      this.x = startx + ( (finalx-startx) * rotation );      
      this.y = starty + ( (finaly-starty) * rotation );;      
      this.angle = startangle + ( (finalangle-startangle) * rotation );      
      this.scale = startscale + ( (finalscale-startscale) * rotation );

      Fx fx = this;
      for(int i=0; i<modificators.size(); i++) {
        Mod mod = (Mod)modificators.get(i);
        //println("Apply mod "+ mod);
        fx=mod.mod(fx);
      }

      return fx;
    }
    public void draw() {
      stg.stroke(this.fxhue, this.fxbw, 100);
      if(fillBw<0) {
        stg.noFill();
      } else {
        stg.fill(fillHue, fillBw, 100);
      }
    }
            
    float getStep() {
      return 1/framerate * bpm/60 / this.duration;
    }
    public Fx bw(float h) {
      this.fxbw = h;
      return this;
    }
    public Fx hue(float h) {
      this.fxhue = h;
      return this;
    }
    public Fx fillbw(float h) {
      this.fillBw = h;
      return this;
    }
    public Fx fillhue(float h) {
      this.fillHue = h;
      return this;
    }
    public Fx framerate(float fr) {
      this.framerate = fr;
      return this;
    }
    public Fx bpm(float bpm) {
      this.bpm = bpm;
      return this;
    }
    public Fx duration(float d) {
      this.duration = d;
      return this;
    }
    public Fx loop(float l) {
      this.loop = l;
      return this;
    }
    public Fx start(float x, float y, float a, float s) {
      this.startx = x;
      this.starty = y;
      this.startangle = a;
      this.startscale = s;
      return this;
    }
    public Fx startPos(float x, float y) {
      this.startx = x;
      this.starty = y;
      return this;
    }
    public Fx startScale(float s) {
      this.startscale = s;
      return this;
    }
    public Fx startAngle(float a) {
      this.startangle = a;
      return this;
    }
    public Fx end(float x, float y, float a, float s) {
      this.finalx = x;
      this.finaly = y;
      this.finalangle = a;
      this.finalscale = s;
      return this;
    }
    public Fx finalPos(float x, float y) {
      this.finalx = x;
      this.finaly = y;
      return this;
    }
    public Fx finalScale(float s) {
      this.finalscale = s;
      return this;
    }
    public Fx finalAngle(float a) {
      this.finalangle = a;
      return this;
    }
  }
  
  public class Gobo {
    
    public float scale = 1;
    public float x = 0;
    public float y = 0;
    public float angle = 0;
    public boolean smooth = true;
    public float framerate = 30;
    public float goboSize = 1/5;
    public float fillHue = 0;
    public float fillBw = 0;
    
    public Gobo() {
    }
    
    public Gobo smooth() {
      this.smooth = true;
      return this;
    }
    public Gobo nosmooth() {
      this.smooth = false;
      return this;
    }
    public Gobo xy(float x, float y) {
      this.x = x;
      this.y = y;
      return this;
    }
    public Gobo scale(float s) {
      this.scale = s;
      return this;
    }
    public Gobo angle(float a) {
      this.angle = a;
      return this;
    }
    public void draw() {
    }
    public Gobo framerate(float f) {
      this.framerate=f;
      return this;
    }
    public Gobo gobosize(float s) {
      this.goboSize=s;
      return this;
    }
    public Gobo fillhue(float h) {
      this.fillHue=h;
      return this;
    }
    public Gobo fillbw(float b) {
      this.fillBw=b;
      return this;
    }

  }

class GoboFx extends Fx {
    private Gobo gobo;
        
    public GoboFx() {
    }
    
    public GoboFx gobo(Gobo gobo) {
      this.gobo=gobo;
      return this;
    }

    public void draw() {
      super.draw();
      this.gobo.framerate(this.framerate);
      this.gobo
        .angle(this.angle)
        .scale(this.scale)
        .xy(this.x, this.y)
        .draw();
    }
  }
}
