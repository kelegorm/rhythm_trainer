#pragma once

#include <math.h>
#include "audio_config.h"
#include "my_log.h"

typedef struct {
    float* data;
    int length; // длина в семплах
} Wave;

Wave getSinewave(int sample_count, float freq);

extern Wave leftSound;
extern Wave rightSound;