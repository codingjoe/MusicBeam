class Beat
{ 
  Boolean hat, snare, kick, onset;

  float level;

  Beat(Boolean h, Boolean s, Boolean k, Boolean o, float l)
  {
    hat = h;
    snare = s;
    kick = k;
    onset = o;
    level = l;
  }
}