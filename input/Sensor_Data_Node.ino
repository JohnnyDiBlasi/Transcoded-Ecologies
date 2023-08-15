#include <Wire.h>
#include "Adafruit_MPR121.h"
#include <Adafruit_DotStar.h>
#include <SPI.h>
#include <SparkFunCCS811.h>
#include <SparkFunBME280.h>

#include "AS726X.h"

#ifdef _BV
#define _BV(bit) (1 << (bit))
#endif

Adafruit_MPR121 cap = Adafruit_MPR121();

uint16_t lastTouched = 0;
uint16_t currTouched = 0;

uint8_t touchedNum = 0;
float capacitance = 0;

//---------------------GLOBAL Sensor Variables------------------------------
#define CCS811_ADDR 0x5B

CCS811 theCCS(CCS811_ADDR);
BME280 theBME;

float dataPoin = 0;
float theData[6];
int idx = 0;

String co2 = "0=";
String temp = "1=";
String pressure = "2=";
String humidity = "3=";
String touch = "4=";
String infrared = "5=";

AS726X spectralSensor;

//---------------------GLOBAL DotStar Variables-----------------------------
#define NUMPIXELS 144
#define DATAPIN 4
#define CLOCKPIN 5

uint16_t red = 0, green = 0, blue = 255;
int theTime = 0;

Adafruit_DotStar strip = Adafruit_DotStar(NUMPIXELS, DATAPIN, CLOCKPIN);

int head = 0;
int tail = -140;


void setup() {
    Wire.begin();
    Serial.begin(115200);

    if (!cap.begin(0x5A)) {
        Serial.print("MPR121 not found, check wiring!");
        while(1);
    }

    //-----------------------Sensor Setup----------------------------------
    //This INITIALIZES the CCS811 Sensor and PRINTS ERROR status of .begin()
    //PRINTING Error-original Example Code does NOT Work:
    //ERROR: 'status' is not a member of 'CCS811Core' error..
    theCCS.begin();

    //Initialize BME280
    //FOr I2C, enable the following and disable the SPI Section
    theBME.settings.commInterface = I2C_MODE;
    theBME.settings.I2CAddress = 0x77;
    theBME.settings.runMode = 3;
    theBME.settings.tStandby = 0;
    theBME.settings.filter = 4;
    theBME.settings.tempOverSample = 5;
    theBME.settings.pressOverSample = 5;
    theBME.settings.humidOverSample = 5;

    //Give Sensor TIME: BME280 Needs 2 ms to Start up
    delay(10);

    byte id = theBME.begin();

    spectralSensor.begin();

    //--------------------------- DotStar Setup-------------------------------
    #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000L)
        clock_prescale_set(clock_div_1);
    #endif
    strip.begin();
    strip.show();
}

void loop() {
    currTouched = cap.touched();

    //NEXT: need to DEBUG the Capacitance sensor..
    for (uint8_t i = 0; i < 12; i++) {
        //it IF *is* touched and *wasnt* touched BEFORE, Alert!
        if ((currTouched & _BV(i)) && !(lastTouched & _BV(i))) {
            //Serial.print(i);
            touchedNum = i;
            capacitance = (float)abs(cap.baselineData(i) - cap.filteredData(i));
            theData[4] = capacitance;
            //Serial.print("Touch sensor # ");
            Serial.print(i);
            //Serial.print(" | The amount of capacitance: ");
            Serial.println(capacitance);
            //CALIBRRATE how much capacitance when actual plant parts hooked up to electrodes are touched...
            red = uint16_t(map(capacitance, 60,220, 150,255));
            green = uint16_t(map(capacitance, 60,220, 100,205));
            blue = 0;
            //Serial.println(" touched");
        }
        //IF it *was* touched now *isnt*, Alert!
        if (!(currTouched & _BV(i)) && (lastTouched & _BV(i))) {
            Serial.print(i);
            //Serial.println(" released");
        }
    }
    //RESET the State
    lastTouched = currTouched;

    /*
    Near IR Readings:
    will be focused on the V and W channels primarily..
    */
    if (spectralSensor.getVersion() == SENSORTYPE_AS7263) {
        theData[5] = spectralSensor.getCalibratedV();
    }

    //-----------------------Sensor Loop-----------------------------------
    if (theCCS.dataAvailable()) {
        theCCS.readAlgorithmResults();
        theData[0] = theCCS.getCO2();
        theData[1] = theBME.readTempF();
        theData[2] = theBME.readFloatPressure();
        theData[3] = theBME.readFloatHumidity();
    }
    else if (theCCS.checkForStatusError()) {
        Serial.println(theCCS.getErrorRegister());
    }

    //idx: 0=co2, 1=temp, 2=pressure, 3=humidity, 4=touch 
    switch (idx) {
        case 0:
            Serial.print(co2);
            Serial.println(theData[idx]);
            if (theData[idx] > 300) {
                theTime = int(map(theData[0], 300,700, 1200,3500));
            }
            else {
                theTime = 2000;
            }
            break;
        case 1:
            Serial.print(temp);
            Serial.println(theData[idx]);
            if (theData[idx] > 60) {
                red = uint16_t(map(theData[1], 60,100, 80,255));
                green = uint16_t(map(theData[1], 60,100, 80,180));
            }
            else {
                red = uint16_t(map(theData[1], 10,60, 0,60));
                green = uint16_t(map(theData[1], 10,60, 255,180));
                blue = 255;
            }
            break;
        case 2:
            Serial.print(pressure);
            Serial.println(theData[idx]);
            green = uint16_t(map(theData[2], 98000,100000, 40,180));
            if (green > 255 || green < 0) green = 255;
            break;
        case 3:
            Serial.print(humidity);
            Serial.println(theData[idx]);
            if (theData[idx] > 50) {
                blue = uint16_t(map(theData[3], 50,90, 150,255));
                red = 20;
                green = uint16_t(map(theData[3], 50,90, 150,255));
            }
            else {
                blue = uint16_t(map(theData[3], 0,50, 0,80));
                green = 255;
                red = 0;
            }
            break;
        case 4:
            Serial.print(touch);
            Serial.println(theData[idx]);
            break;
    }

    idx++;
    if (idx > 4) idx = 0;

    //Safety: Constraining the COLOR Values
    if (red < 0) {
        red = 40;
    }
    else if (red > 255) {
        red = 255;
    }

    if (green < 0) {
        green = 0;
    }
    else if (green > 255) {
        green = 255;
    }

    if (blue < 0) {
        blue = 0;
    }
    else if (blue > 255) {
        blue = 255;
    }

    //--------------------------- DotStar Loop--------------------------------
    strip.setPixelColor(head, green, red, blue);
    strip.setPixelColor(tail, 0);
    strip.show();
    delay(20);

    if (++head >= NUMPIXELS) {
        head = 0;
    }
    if (++tail >= NUMPIXELS) {
        tail = 0;
    }
}





