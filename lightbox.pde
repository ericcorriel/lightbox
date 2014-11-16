/*Step 1: Define our variables */

PFont font;              //used for displaying annotations
int numProjectors;       //number of planes of light we're going to project 
int projectorWidth;      //projector resolution width
int projectorHeight;     //projector resolution height 
int timeToChangeColors;  //how long each color should stay active before changing 

//define our array of colors that will be randomly displayed
//colors are set by specifying Red, Green, Blue values on a scale from 0 (none) to 255 (full color)
//it's easy to get RGB values from Photoshop or http://www.rapidtables.com/web/color/RGB_Color.htm
color[] colors = new color[8];
color red  = color(255, 0, 0);
color blue  = color(0, 0, 255);
color green  = color(0, 255, 0);
color cyan  = color(0, 255, 255);
color magenta  = color(255, 0, 255);
color yellow  = color(255, 255, 0);
color purple = color(144, 0, 255);
color orange = color(255, 144, 0);

//define variables to hold current and next color values
color currentHorizColor;    //current color of the horizontal color planes
color nextHorizColor;       //next color of the horizontal color planes
color currentVertColor;     //current color of the vertical color planes    
color nextVertColor;        //next color of the vertical color planes

/*Step 2: Set script properties and populate our variables */
void setup() {
  background(0);                          //set background to black
  size(1024, 192);                        //set the "canvas" size; how big this animation will be
  font = createFont("Arial", 16, true);   //set the font for the annotations

  numProjectors = 4;                      //4 channel video installation
  projectorWidth = 256;                   //normally this would be the resolution of a VGA projector: 1024
  projectorHeight = 192;                  //normally 768, but for the purposes of this demonstration, we set it lower
  timeToChangeColors = 100;               //how long each color will stay up for, in milliseconds

  //populate the colors array
  colors[0] = red;
  colors[1] = green;
  colors[2] = blue;
  colors[3] = cyan;
  colors[4] = magenta;
  colors[5] = yellow;
  colors[6] = purple;
  colors[7] = orange;
  
  updateColors();
}

/*Step 3: let's draw! */
void draw() {
  /*
  * the percent sign is the modulus operator, which returns the remainder of a division equation
  * for example, 12%10 returns 2 || 3%3 returns 0 (no remainder) || 123 % 100 returns 23
  * in this case we want to call updateColors every 100 frames
  * so when frameCount%timeToChangeColors gives a zero remainder
  * for example, if we're on frame 453, frameCount*timeToChangeColors would give a remainder of 53
  * if we're on frame 600 then we'd get a remainder of 0, which will trigger updateColors()
  */
  if (frameCount%timeToChangeColors==0) {
    updateColors();
  }
  
  /*
  * the goal is to gradually shift between currentHorizColor and nextHorizColor (same for currentVertColor and nextVert Color)
  * imagine for simplicity's sake that we're starting with a black square and want to gradually change its color to white
  * passing through lots of shades of gray in the process, over the span of 100 frames
  * if we assign numerical values to each color and say that black = 0 and white = 255 
  * and that on frame 1 the color of our rectangle is black (0) and that on frame 100 we want it to be white (255)
  * and that on frame 50, for example, we want it to be gray (128) 
  * then we need a way to calculate, based on what frame we're on, what shade of gray our rectangle should be,
  * which is to say, what number, on a scale of 0 (black) - 255 (white), we should assign to our rectangle
  *
  * let's breakdown the line below:
  * frameCount%timeToChangeColors: takes the number of the current frame (which increases by 60 every second) and
  * gives us the frame number *relative to* our timeToChangeColors
  * so like the example above, if we're on frame 453 and we set timeToChangeColors = 100 then, 
  * frameCount%timeToChangeColors will give us 53
  * in order for lerpColor to work (https://www.processing.org/reference/lerpColor_.html) we need to give it
  * startColor, endColor, and gradientPercentage, which will calculate the color that's gradientPercentage between startColor and endColor
  * note that gradientPercentage must be a decimal value between 0 and 1
  * 
  * the map function (https://www.processing.org/reference/map_.html) takes a value and a value range and maps it to a different value range
  * so map(.5, 0, 1, 0, 1000) says: if we give the map function a value of .5 and say that this value exists on a scale of 0 to 1, but we want to find
  * the same relative value on a scale of 0 to 1000, then the map function would return 500.  just like .5 is halfway between 0 and 1, 500 is halfway between 0 and 1000
  * so this line takes the current frame, relative to our timeToChangeColors (53 in this example)
  * and says that this value currently exists on a scale of 0 to timeToChangeColors (which we set to 100) and asks for the relative value of this number
  * on a scale of 0 to 1, which is what is required by lerpColor
  * so in this case, gradientPercentage would be .53, which would be just slightly darker than the gray that's halfway between white and black
  */
  float gradientPercentage = map(frameCount%timeToChangeColors, 0, timeToChangeColors, 0, 1);
  
  
  //we need to loop through each projector to set the color for each projector
  for (int i=0; i<numProjectors; i++) {
    /*
    * the sketch will output numProjectors (in this case 4) rectangles of varying color
    * the rectangles will be left-aligned, each one butting up against the rightmost edge of the previous rectangle, effectively forming a strip of rectangles
    * if we're outputting to 4 VGA projectors, which have a native resolution of 1024 x 768, then our sketch will be 4096px wide and 768px high
    * imagine a computer with four small old school monitors connected to it, these monitors have a resolution of 1024 x 768.
    * then imagine you open a really wide quicktime movie that perfectly spans these four monitors.
    * then just replace these monitors with projectors and you have a 4 channel projector installation
    * 
    * the way this sketch is set up, rectangles 1 and 3 will display on the vertically oriented projectors and rectangles 2 and 4 will display on the 
    * horizontally oriented projectors
    * if(i%2==0) says that, while we're looping through each projector, if we're on projectors 2 or 4 (where i == 0 or i == 2), then set the fill color
    * to the currentHorizColor
    * if the index of the loop is an odd number (i == 1 or i == 3) then set the fill color to the currentVertColor
    */
    if (i%2==0) fill(lerpColor(currentHorizColor, nextHorizColor, gradientPercentage));
    else fill(lerpColor(currentVertColor, nextVertColor, gradientPercentage));
    
    /*
    * using the rect function (https://processing.org/reference/rect_.html)
    * draw a solid color rectangle in the right place
    * so if i == 0 (first projector) draw a rectangle at (0,0) that has a width of projectorWidth (normally 1024) and a height of projectorHeight (normally 768)
    */
    rect(projectorWidth * i, 0, projectorWidth, projectorHeight);
  }
  //for presentation purposes, draw lables
  drawAnnotations();
}

/*
* imagine this sketch has been running for 5 minutes and that currentHorizColor is red and currentVertColor is blue
* also imagine that nextHorizColor is green and nextVertColor is magenta
* we also know that the goal of this sketch is to slowly migrate from currentHorizColor to nextHorizColor 
* so when it's time to change colors, i.e., when this function is called, we know that we have finished migrating from currentHorizColor to nextHorizColor
* so the state of our color situation is that the projectors are displaying nextHorizColor and nextVertColor
* 
* since that's the case, we can say that the currentHorizColor is equal to nextHorizColor
* and then we need to find a new color to migrate to
*/
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

