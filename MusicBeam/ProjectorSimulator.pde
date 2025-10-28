// Projector Simulator
// Author: Luis Quinones
// May - June 2018
// Description: 
//   - This tool is meant to help visualize the beams that are created from a 
//       projector
//   - It gives a better understanding of the feel and look of both the effect and
//     the room the projector is in
//   - A stage instance is responsible for initializing and starting the thread
//   - The stage instance that is responsible for Projector Simulator object
//     is suppose to call setImage() on its draw()
// Controls:
//   Keys 'w' and 's' zooms the camera in and out

public class ProjectorSimulator extends PApplet {

  // Stage's image: The light beams are
  // created based off of this image
  private PImage projImg;

  // Processing 3D camera's parameters
  private float eyeX, eyeY, eyeZ, sceneX, sceneY, sceneZ;

  // The room's (box's) dimensions
  private float roomWidth, roomHeight, roomDepth;

  // Used for Standard and Retina (High-DPI Display)
  // Used for stroke weight of beam; 1 = Standard, 2 = Retina
  private float beamWeight;

  // The number of rows and columns skipped for efficiency
  int skip;

  public ProjectorSimulator() {
    super();
  }

  public void settings() {
    pixelDensity(displayDensity());
    beamWeight = pixelDensity;
    size(800, 600, P3D);
  }

  public void setup() {    
    projImg = createImage(800, 600, ARGB); 

    roomWidth = projImg.width;
    roomHeight = projImg.height;
    roomDepth = 500;

    sceneX = roomWidth / 2.0;
    sceneY = roomHeight / 2.0;
    sceneZ = -1.0 * roomDepth / 2.0;

    eyeX = sceneX;
    eyeY = sceneY;
    eyeZ = roomDepth;

    skip = 2;
  }

  // Sets the image that the simulation is based on
  public void setImage(PImage img) {
    projImg = img;
  }

  public void draw() {
    background(120);

    if (keyPressed) {
      handleKeyPressed();
    }

    camera(eyeX, eyeY, eyeZ, sceneX, sceneY, sceneZ, 0, 1, 0);

    drawBeams();
    drawRoom();
  }

  // Handles key presses
  // 'w' and 's' for zooming camera
  private void handleKeyPressed() { 
    if (keyPressed) {
      if (key == 'w') {
        eyeZ -= 10;
      } else if (key == 's') {
        eyeZ += 10;
      }
    }
  }

  // Draw lines that simulates the 
  // beams from a projector
  private void drawBeams() {
    pushMatrix();
    blendMode(ADD);
    translate(projImg.width, 0, 0);
    rotateY(PI);
    strokeWeight(beamWeight);
    projImg.loadPixels();

    // Loops through every* pixel in the projector image and create a 
    // line. The line represents a light beam.
    // * The nested loops skips rows and columns for efficiency 
    for (int y = 0; y < projImg.pixelHeight; y += (skip*beamWeight)) {
      for (int x = 0; x < projImg.pixelWidth; x += (skip*beamWeight)) {   
        int loc = x + y * width;
        color c = projImg.pixels[loc]; 
        if (c !=0 && c != color(0)) {
          stroke(c, 25);
          line(x, y, 0, roomWidth / 2, roomHeight / 2, roomDepth);
        }
      }
    }
    projImg.updatePixels();    
    popMatrix();
  } 

  // Draws outline of the room
  private void drawRoom() {
    blendMode(BLEND);
    pushMatrix();
    translate(roomWidth / 2, roomHeight / 2, -1 * roomDepth / 2);
    noFill();
    stroke(0);
    box(roomWidth, roomHeight, roomDepth);
    popMatrix();
  }
}