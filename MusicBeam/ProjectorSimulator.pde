public class ProjectorSimulator extends PApplet{
  
  private PImage projImg;
  private float eyeX,eyeY,eyeZ,sceneX,sceneY,sceneZ;
  private float cameraDistance, cameraTheta, cameraPhi;
  
  public ProjectorSimulator(){
    super(); 
  }
  
  public void settings() {
    pixelDensity(displayDensity());
    size(800, 600, P3D);
  }
  
  public void setup(){    
    projImg = createImage(800,600,ARGB);
  
    eyeX = 0;
    eyeY = 0;
    eyeZ = 1;
 
    sceneX = width/2;
    sceneY = height/2;
    sceneZ =-250;
  
    cameraDistance = 250;
    cameraTheta = 0.01;
    cameraPhi = PI/2;
}
  
  public void setImage(PImage img){
    projImg = img;
  }
  
  public void draw(){
    background(120);
    if(keyPressed)
      handleKeyPressed();
    camera(eyeX,eyeY,eyeZ,sceneX,sceneY,sceneZ,0,1,0);
    float [] coord= toCartesian(cameraDistance, cameraTheta,cameraPhi);
    
    eyeX = sceneX + coord[0];
    eyeY = sceneY + coord[1];
    eyeZ = sceneZ + coord[2];
        
    //drawImage();  //uncomment to see image from stage
    drawBeams();
    drawRoom();    
  }
  
  private void handleKeyPressed(){
    if(keyPressed){
    if(key == 'w'){
      cameraDistance -=10;
    }
    else if(key == 'a'){
     cameraTheta -=0.1;
    }
    else if(key =='s'){
     cameraDistance +=10;
    }
    else if(key =='d'){
      cameraTheta +=0.1;
    }   
    else if(key == 'q'){
     cameraPhi -=0.1;
    }
    else if(key == 'e'){
      cameraPhi +=0.1;
    }
    else if(key ==CODED){
      if(keyCode == UP){
        sceneZ -= 10;
      }
      else if(keyCode ==DOWN){
        sceneZ +=10;
      }
      else if(keyCode == LEFT){
      sceneX -=10;
      }
      else if(keyCode == RIGHT){
        sceneX += 10;
      }
    }
  }
  }
  private float [] toCartesian(float p, float theta, float phi){
  float x = p * sin(phi)*cos(theta);
  float y = p * sin(phi)*sin(theta);
  float z = p * cos(phi);
  float [] r = {y,z,x};
  return r;  
}

  private void drawBeams(){
    stroke(0,120);
    pushMatrix();
    blendMode(ADD);
    translate(projImg.width,0,0);
    rotateY(PI); 
    strokeWeight(1);
    
    projImg.loadPixels();
    for(int y=0; y<projImg.height; y+=2){
    for (int x =0; x<projImg.width; x+=2){   
      int loc = x + y * width;
      if( projImg.pixels[loc] !=0 && projImg.pixels[loc] != color(0)){
        //img.pixels[loc] = color(0,255,255);
        stroke(projImg.pixels[loc],25);          
        line(x,y,0,width/2,height/2,500);       
      }
     }
    }
    projImg.updatePixels();    
    popMatrix();
  }
  
  private void drawRoom(){
    blendMode(BLEND);
    pushMatrix();
    translate(width/2,height/2,-250);
    noFill();
    stroke(0);
    box(projImg.width,projImg.height, 500);
    popMatrix();   
  }
  
  private void drawImage(){
    pushMatrix();
    translate(projImg.width,0,0);
    rotateY(PI); 
    image(projImg,0,0);
    popMatrix();
  }
}