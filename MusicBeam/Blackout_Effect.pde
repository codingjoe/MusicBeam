class Blackout_Effect extends Effect
{
  String getName() {
    return "Blackout";
  }
  
  char triggeredByKey() {
    return '0';
  }

  boolean moving = false;

  Blackout_Effect(MusicBeam ctrl, int y)
  {
    super(ctrl, y);
  }

  void draw()
  {
  }
}