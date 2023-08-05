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

void setup() {
    Wire.begin();
    Serial.begin(115200);
}





