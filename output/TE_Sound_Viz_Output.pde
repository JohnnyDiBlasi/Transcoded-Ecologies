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

    float mapData = map(soundDataOne, -40,40, height-1300,height-1450);
    float twoMapData = map(soundDataTwo, -40.0,40.0, height-1050,height-1200);
    float threeMapData = map(soundDataThree, -40.0,40.0, height-800,height-950);
    float fourMapData = map(soundDataFour, -40.0,40.0, height-550,height-700);
    float fiveMapData = map(soundDataFive, -40.0,40.0, height-300,height-450);
    
    labelOne = "The incoming temperature data: " + soundDataOne + " C";
    fill(360);
    textFont(ttlType, 36);
    
    hData = "" + soundDataTwo;
    tempData = "" + soundDataOne;
    
    yearData = "" + soundDataThree;
    dayData = "" + soundDataFour;
    hourData = "" + soundDataFive;
    
    fill(120,0,100);
    
    text(sourceLabel, width-1400, height-1175);
    text(sourceData, width-1000, height-1175);
    
    text(speciesLabel, width-1400, height-1135);
    text(speciesData, width-1000, height-1135);
    
    text(hourLabel, width-1800, height-500);
    text(hourData, width-1400, height-500);
    
    text(dayLabel, width-1800, height-300);
    text(dayData, width-1400, height-300);
    
    
    text(yearLabel, width-1800, height-100);
    text(yearData, width-1400, height-100);
    
    textFont(ttlType, 32);
    text(tempLabel, width-1800, height-950);
    text(tempData, width-1400, height-950);
    text(tLabel, width-750, height-950);
    
    text(hLabel, width-1800, height-700);
    text(hData, width-1400, height-700);
    text(percentLabel, width-750, height-700);

    gridOne.updateTargets(mapData);
    gridTwo.updateTargets(twoMapData);
    gridThree.updateTargets(threeMapData);
    gridFour.updateTargets(fourMapData);
    gridFive.updateTargets(fiveMapData);

    noFill();
    stroke(0,100);
    strokeWeight(lineWeight);
    bezierDetail(10);
    
    //Step 3 Draw: SET the VIEW/ROTATION of the MATRIX:
    pushMatrix();
    //translate(width/2, height/2);
    translate(width*0.5, height*0.25, -50);
    if (mousePressed && mouseButton==RIGHT) {
        offsetX = (mouseX-clickX);
        offsetY = (mouseY-clickY);
        
        targetRotationX = min(max(clickRotationX + offsetY/float(width) * TWO_PI, -HALF_PI), HALF_PI);
        targetRotationY = clickRotationY + offsetX/float(height) * TWO_PI;
    }
    rotationX += (targetRotationX - rotationX)*0.25;
    rotationY += (targetRotationY - rotationY)*0.25;
    rotateX(rotationX);
    rotateY(rotationY);

    gridFive.drawGrid();
    gridFour.drawGrid();
    gridThree.drawGrid();
    gridFour.drawGrid();
    gridFive.drawGrid();

    popMatrix();

    // The Change Boolean-randomly changing the Index and inByte Value
    // (BACKUP for NO Incoming Data) -or- Put this as an ELSE tied to if stmt below
    if (time % 12 == 0) {
        change = !change;
    }
    if (dataIdx > 4) dataIdx = 0;
    
    if (time % 5 == 0) {
        switch (dataIdx) {
        case 0:
            dataPoint = "co2";
            if (change) {
                println("Change boolean is true. Changing co2 Frequency");
                inByte = float(505);
            }
            else {
                inByte = float(500);
            }
            println("First dataset co2 run");
            break;
        case 1:
            dataPoint = "temp";
            if (change) {
                println("Change boolean is true. Changing co2 Frequency");
                inByte = float(81);
            }
            else {
                inByte = float(80);
            }
            //inByte = float(80);
            println("Second dataset temp run");
            break;
        case 2:
            dataPoint = "pressure";
            if (change) {
                println("Change boolean is true. Changing co2 Frequency");
                inByte = float(98010);
            }
            else {
                inByte = float(98000);
            }
            //inByte = float(98000);
            println("Third dataset pressure run");
            break;
        case 3:
            dataPoint = "humidity";
            if (change) {
                println("Change boolean is true. Changing co2 Frequency");
                inByte = float(41);
            }
            else {
                inByte = float(40);
            }
            //inByte = float(40);
            println("Fourth dataset humidity run");
            break;
        case 4:
            dataPoint = "capacitance";
            if (change) {
                println("Change boolean is true. Changing co2 Frequency");
                inByte = float(252);
            }
            else {
                inByte = float(250);
            }
            //inByte = float(250);
            println("Fifth dataset touch run");
            break;
        //end data switching..
        }
        //dataIdx++;
        dataIdx = int(floor(random(0,5)));
    }
    
    //ADD the Idx increment and 'change' datapoint cycle for inByte here..

    sendData();
    if (inByte != prevVal) {
        if (dataPoint.equals(s1)) {
            if (inByte > 300 && inByte <= 500) {
                float dataMap = map(inByte, 300,500, 54,108);
                if (dataMap > 108 || dataMap < 0) dataMap = 108;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 500 && inBYte <= 700) {
                float dataMap = map(inByte, 500,700, 54,108);
                if (dataMap > 108 || dataMap < 0) dataMap = 108;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else {
                float dataMap = 108;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
        }
        //Temp F-G
        if (dataPoint.equals(s2)) {
            if (inByte > 40 && inByte <= 60) {
                float dataMap = map(inByte, 40,60, 48,192);
                if (dataMap > 108 || dataMap < 0) dataMap = 192;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 60 && inByte <= 80) {
                float dataMap = map(inByte, 60,80, 48,192);
                if (dataMap > 108 || dataMap < 0) dataMap = 192;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 80 && inByte <= 100) {
                float dataMap = map(inByte, 80,100, 48,192);
                if (dataMap > 108 || dataMap < 0) dataMap = 192;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else {
                float dataMap = 192;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
        }
        else if (dataPoint.equals(s3)) {
            //Pressure - D
            if (inByte > 3000 && inByte <= 98000) {
                //D - Pressure - two Octaves here - DECIDE: ONE or TWO Octaves
                float dataMap = map(inByte, 92000,98000, 72,288);
                if (dataMap > 288 || dataMap < 0) dataMap = 288;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 98000 && inByte <= 99000) {
                float dataMap = map(inByte, 98000,99000, 72,288);
                if (dataMap > 288 || dataMap < 0) dataMap = 288;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 99000 && inByte <= 100000) {
                float dataMap = map(inByte, 99000,100000, 72,288);
                if (dataMap > 288 || dataMap < 0) dataMap = 288;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 100000 && inByte <= 101000) {
                float dataMap = map(inByte, 100000,101000, 72,288);
                if (dataMap > 288 || dataMap < 0) dataMap = 288;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
        }
        else if (dataPoint.equals(s4)) {
            //Humidity - C
            if (inByte > 5 && inByte <= 20) {
                float dataMap = map(inByte, 5,20, 64,128);
                if (dataMap > 128 || dataMap < 0) dataMap = 128;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 20 && inByte <= 40) {
                float dataMap = map(inByte, 20,40, 64,128);
                if (dataMap > 128 || dataMap < 0) dataMap = 128;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 40 && inByte <= 60) {
                float dataMap = map(inByte, 40,60, 64,128);
                if (dataMap > 128 || dataMap < 0) dataMap = 128;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 60 && inByte <= 80) {
                float dataMap = map(inByte, 60,80, 64,128);
                if (dataMap > 128 || dataMap < 0) dataMap = 128;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
        }
        else if (dataPoint.equals(s5)) {
            //Capatinance - B
            if (inByte > 100 && inByte <= 150) {
                float dataMap = map(inByte, 100,150, 60.75,121.5);
                if (dataMap > 121.5 || dataMap < 0) dataMap = 121.5;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 150 && inByte <= 250) {
                float dataMap = map(inByte, 150,250, 60.75,121.5);
                if (dataMap > 121.5 || dataMap < 0) dataMap = 121.5;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
            else if (inByte > 250  && inByte < 350) {
                float dataMap = map(inByte, 250,350, 60.75,121.5);
                if (dataMap > 121.5 || dataMap < 0) dataMap = 121.5;
                freqs[idx] = dataMap;
                waves[idx].setFrequency(freqs[idx]);
            }
        }
        idx++;
        if (idx > 4) idx = 0;
        prevVal = inByte;
    }

    theString1 = ""+freqs[0];
    theString2 = ""+freqs[1];
    theString3 = ""+freqs[2];
    theString4 = "" + freqs[3];
    theString5 = ""+freqs[4];
    fill(120,0,100);
    textFont(ttlType, 32);
    //fill(255);
    text(theString1, width-1000, height-950);
    text(theString2, width-1000, height-700);
    text(theString3, width-1000, height-500);
    //textSize(36);
    text(theString4, width-1000, height-300);
    text(theString5, width-1000, height-100);

}

public void teSoundWaves(float waveOne, float waveTwo) {
    soundDataOne = waveOne;
    soundDataTwo = waveTwo;
}

public void teSoundWavesTwo(float waveThree, float waveFour, float waveFive) {
    soundDataThree = waveThree;
    soundDataFour = waveFour;
    soundDataFive = waveFive;
}

void oscEvent(OscMessage theOscMessage) {
    if (theOscMessage.isPlugged() == false) {
        println("### received an osc message.");
        println("### addrpattern\t"+theOscMessage.addrPattern());
        println("### typetag\t"+theOscMessage.typetag());
    }
}


void sendData() {
    OscMessage waveMsg = new OscMessage("/filter");
    if (ii > buffersize-1) ii = 0;
    waveMsg.add(theOuts[0].mix.get(ii)*50);
    waveMsg.add(theOuts[1].mix.get(ii)*50);

    theOsc.send(waveMsg, theRemoteLocation);

    OscMessage waveTwoMsg = new OscMessage("/time");
    waveTwoMsg.add(theOuts[2].mix.get(ii)*50);
    waveTwoMsg.add(theOuts[3].mix.get(ii)*50);
    waveTwoMsg.add(theOuts[4].mix.get(ii)*50);

    theOsc.send(waveTwoMsg, theRemoteLocation);
    ii++;
}

void serialEvent(Serial thePort) {
    String inString = thePort.readStringUntil('\n');
    if (inString != null) {
        inString = trim(inString);
        String[] theData = split(inString, "=");
        dataPoint = theData[0];
        dataIdx = int(theData[0]);
        inByte = float(theData[1]);
        println("Incoming DATA was successfully converted from String to numerical values:");
        println("The Received Index number was " + dataIdx);
        println("The Received Data Float Value was " + inByte);
        switch(dataIdx) {
            case 0:
                dataPoint = "co2";
                break;
            case 1:
                dataPoint = "temp";
                break;
            case 2:
                dataPoint = "pressure";
                break;
            case 3:
                dataPoint = "humidity";
                break;
            case 4:
                dataPoint = "capacitance";
                break;
        }
    }
}

