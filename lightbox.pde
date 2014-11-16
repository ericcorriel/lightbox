PFont font;
int numProjectors;
int projectorWidth;
int projectorHeight;
int speed;

color[] colors = new color[8];
color red  = color(255, 0, 0);
color blue  = color(0, 0, 255);
color green  = color(0, 255, 0);
color cyan  = color(0, 255, 255);
color magenta  = color(255, 0, 255);
color yellow  = color(255, 255, 0);
color purple = color(144, 0, 255);
color orange = color(255, 144, 0);
color black = color(0);
color white = color(255);

color currentHorizColor;
color nextHorizColor;
color currentVertColor;
color nextVertColor;

void setup() {
  background(0);
  size(1024, 192);
  font = createFont("Arial", 16, true);

  numProjectors = 4;
  projectorWidth = 256;
  projectorHeight = 192; 
  speed = 100;

  colors[0] = red;
  colors[1] = green;
  colors[2] = blue;
  colors[3] = cyan;
  colors[4] = magenta;
  colors[5] = yellow;
  colors[6] = purple;
  colors[7] = orange;
}


void draw() {

  if (frameCount%speed==0) {
    updateColors();
  }
  float lerpPercentage = map(frameCount%speed, 0, speed, 0, 1);
  for (int i=0; i<numProjectors; i++) {
    if (i%2==0) fill(lerpColor(currentHorizColor, nextHorizColor, lerpPercentage));
    else fill(lerpColor(currentVertColor, nextVertColor, lerpPercentage));
    rect(projectorWidth * i, 0, projectorWidth, projectorHeight);
  }
  drawAnnotations();
}


void updateColors() {
  currentHorizColor = nextHorizColor;
  currentVertColor = nextVertColor;
  nextHorizColor = colors[(int)random(colors.length)];
  nextVertColor = colors[(int)random(colors.length)];
}


void drawAnnotations() {
  textFont(font);
  fill(255, 0, 0);
  for (int i=0; i<width; i+=width/4) {
    text("Projector " + ((i/256)+1), i+15, 20);
  }
}

