import processing.serial.*;

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
//For AudiioStream
import ddf.minim.spi.*;

import processing.opengl.*;
import oscP5.*;
import netP5.*;

OscP5 theOsc;
NetAddress theRemoteLocation;

boolean invertBackground = false;
float lineWeight = 1.5;
float lineAlpha = 50;

Grid gridOne;
Grid gridTwo;
Grid gridThree;
Grid gridFour;
Grid gridFive;

int theMaxCount = 20;
int theXCount = 18;
int theYCount = 4;
int theZCount = 3;

int theOldXCount = theXCount;
int theOldYCount = theYCount;
int theOldZCount = theZCount;

float theGridStepX = 29;
float theGridStepY = 20;
float theGridStepZ = 100;
float theOldGridStepX;
float theOldGridStepY;
float theOldGridStepZ;

float theNodeRadius = 100;
float theNodeRamp = 3.125;
float theNodeScale = 1.325;
float theNodeDamping = 0.4;

boolean theDrawX = true;
boolean theDrawY = true;
boolean theDrawZ = true;

float theNodeMax = 30;
float theNodeMid = 15;

boolean theInvertBackground = false;
float theLineWeight = 1.0;
float theLineAlpha = 50;

boolean theDrawCurves = false;
boolean theDrawLines = !theDrawCurves;

int gridOneBase;
int gridTwoBase;
int gridThreeBase;
int gridFourBase;
int gridFiveBase;

// -------- mouse interaction --------
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY;
boolean mouseInWindow = false;


PImage logo;
PImage planet;

String labelOne = "";
String sourceLabel = "Data source(s):";
String sourceData = "CO2 / Temperature / Humidity";

String hourLabel = "Output Three:";
String hourData = "";

String dayLabel = "Output Four:";
String dayData = "";

String yearLabel = "Output Five:";
String yearData = "";

String tempLabel = "Output One:";
String tempData = "";
String tLabel = "Celsius";

String hLabel = "Output Two:";
String hData = "";
String percentLabel = "%";

String speciesLabel = "Species:";
String speciesData = "Various";

float soundDataOne = 0.0;
float soundDataTwo = 0.0;

float soundDataFive = 0;
float soundDataFour = 0;
float soundDataThree = 0;

PFont ttlType;
PFont sType;

String credit1 = "Carlos Castellanos & Johnny DiBlasi";
String credit2 = "Visualization & GPL License";
String credit3 = "by Johnny DiBlasi";


//------------------------Serial Output Globals--------------------------------
Serial thePort;
float inByte = 0;
int dataIdx = 0;
String dataPoint = "";
String s1 = "co2";
String s2 = "temp";
String s3 = "pressure";
String s4 = "humidity";
String s5 = "capacitance";
int idx = 0;
int time = 0;

boolean change = false;

//------------------------Minim Output Globals---------------------------------
Minim theMinim;
int waveCount = 5;
int buffersize = 1024;
AudioOutput[] theOuts = new AudioOutput[waveCount];
Oscil[] waves = new Oscil[waveCount];
float[] inputData = {0.096, 0.108, 0.1215, 0.128, 0.144};

float[] freqs = new float[waveCount];
int ii = 0;
float prevVal = 0;


String theString1 = "";
String theString2 = "";
String theString3 = "";
String theString4 = "";
String theString5 = "";

int buffIdx = 0;


void setup() {
    size(displayWidth, displayHeight, P3D);
    smooth();

    frameRate(15);

    //-------------------- OSC & Data Grid Setup -------------------------
  ttlType = createFont("SourceCodePro-Light.ttf", 150);
  sType = createFont("SourceCodePro-ExtraLight.ttf", 14);
  
  gridOneBase = 1300;
  gridTwoBase = 1050;
  gridThreeBase = 800;
  gridFourBase = 550;
  gridFiveBase = 300;
  
  //setParas(xCount,yCount,zCount, 45,200,100, 30,15, 100,3.125,1.325,0.7, false, 1,50, true,true,true, false);
  gridOne = new Grid(theXCount, theYCount, theZCount, theGridStepX, theGridStepY, theGridStepZ, 
  theMaxCount, theNodeMax, theNodeMid,
  theNodeRadius, theNodeRamp, theNodeScale, theNodeDamping,
  theInvertBackground, theLineWeight, theLineAlpha,
  theDrawX, theDrawY, theDrawZ, theDrawCurves, gridOneBase);

  gridTwo = new Grid(theXCount, theYCount, theZCount, theGridStepX, theGridStepY, theGridStepZ, 
  theMaxCount, theNodeMax, theNodeMid,
  theNodeRadius, theNodeRamp, theNodeScale, theNodeDamping,
  theInvertBackground, theLineWeight, theLineAlpha,
  theDrawX, theDrawY, theDrawZ, theDrawCurves, gridTwoBase);

  gridThree = new Grid(theXCount, theYCount, theZCount, theGridStepX, theGridStepY, theGridStepZ, 
  theMaxCount, theNodeMax, theNodeMid,
  theNodeRadius, theNodeRamp, theNodeScale, theNodeDamping,
  theInvertBackground, theLineWeight, theLineAlpha,
  theDrawX, theDrawY, theDrawZ, theDrawCurves, gridThreeBase);

  gridFour = new Grid(theXCount, theYCount, theZCount, theGridStepX, theGridStepY, theGridStepZ, 
  theMaxCount, theNodeMax, theNodeMid,
  theNodeRadius, theNodeRamp, theNodeScale, theNodeDamping,
  theInvertBackground, theLineWeight, theLineAlpha,
  theDrawX, theDrawY, theDrawZ, theDrawCurves, gridFourBase);

  gridFive = new Grid(theXCount, theYCount, theZCount, theGridStepX, theGridStepY, theGridStepZ, 
  theMaxCount, theNodeMax, theNodeMid,
  theNodeRadius, theNodeRamp, theNodeScale, theNodeDamping,
  theInvertBackground, theLineWeight, theLineAlpha,
  theDrawX, theDrawY, theDrawZ, theDrawCurves, gridFiveBase);

  /*
  reset(1300);
  resetT(1050);
  resetThree(800);
  resetFour(550);
  resetFive(300);
  */
  
  logo = loadImage("phylum_logo.jpg");
  planet = loadImage("planet.jpg");
  
  /* start oscP5, listening for incoming messages at port 12000 */
  theOsc = new OscP5(this, 120000);
  // creat a NetAddress for sending OSC (to this sketch - for testing)// creat a NetAddress for sending OSC (to this sketch - for testing)
  theRemoteLocation = new NetAddress("127.0.0.1", 12000);

  /*
  OSC Plug Service:
  OSC messages with a specific address pattern can be automatically
  forwarded to a specific method of an object. 
  
  Here, each message with address pattern /filter and typetag 
  ff will be forwarded to the methods: 
  teSoundWaves(float temperature, float humidity) and the
  address pattern /time and typetag iii will be forwarded to
  the method teSoundWavesTwo(int year, int day, int hour)
  */
  theOsc.plug(this, "teSoundWaves", "/filter");
  theOsc.plug(this, "teSoundWavesTwo", "/time");

  //----------------- Oscils wSerial Data Setup ------------------------\
  printArray(Serial.list());

  thePort = new Serial(this, Serial.list()[1], 115200);
  thePort.bufferUntil('\n');

  theMinim = new Minim(this);
  for (int i = 0; i < waveCount; i++) {
    theOuts[i] = theMinim.getLineOut(Minim.STEREO, buffersize);
    freqs[i] = inputData[i] * 1000;
    waves[i] = new Oscil(freqs[i], 0.8, Waves.SINE);
    waves[i].patch(theOuts[i]);
  }
}


void draw() {
    colorMode(HSB, 360, 100, 100,100);
    color bgColor = color(0);
    color circleColor = color(0);
    if (invertBackground) {
        bgColor = color(0);
        circleColor = color(360);
    }
    
    time = second();
    
    if (buffIdx > buffersize-1) buffIdx=0;
    pushMatrix();
    translate(-990,-620,-750);
    noStroke();
    //fill(bgColor, 5);
    fill(bgColor);
    rect(0,0,3900,2500);
    popMatrix();

    // float mapData = map();
}

