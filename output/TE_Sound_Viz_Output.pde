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

void setup() {
    size(displayWidth, displayHeight, P3D);
    smooth();
}


