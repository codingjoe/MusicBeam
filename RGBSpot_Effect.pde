class RGBSpot_Effect extends Effect
{
  String getName() {return "RGB Spot";}
  
  RGBSpot_Effect(MusicBeam ctrl)
  {
    super(ctrl);
  }
  
  float rx = 0;
  
  float ry = 0;
  
  float rc = 0;
  
  int timer = 0;
  
  int delay = 20;
  
  void draw()
  {
    stg.fill(60*rc,100,100);
    if (isKick()&&isOnset()&&timer==0) {
      rx = random(-1,1);
      ry = random(-1,1);
      rc = random(0,6);
      timer = delay;
    }
    
    stg.ellipse(((stg.width/2)*rx), (stg.height/2)*ry, stg.minRadius/4, stg.minRadius/4);
    
    if (timer>0)
      timer--;
  }
}

