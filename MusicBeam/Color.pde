class Color{
  int r,g,b;
  // Create a 24 bit color value from R,G,B
  Color(int r, int g, int b)
  {
    this.r=r;
    this.g=g;
    this.b=b;
  }
  Color(){};

}

//Input a value 0 to 255 to get a color value.
//The colours are a transition r - g -b - back to r
Color Wheel(int WheelPos)
{
  if (WheelPos < 85) {
   return new Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
   WheelPos -= 85;
   return new Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170; 
   return new Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}


