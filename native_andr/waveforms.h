#pragma once

#include <math.h>
#include "audio_config.h"
#include "my_log.h"

typedef struct {
    float* data;
    int length; // длинна в семплах
    int currentIndex;  // Текущий индекс воспроизведения
    bool isPlaying;    // Активен ли звук
} Wave;

extern Wave leftSound;
extern Wave rightSound;