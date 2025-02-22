#pragma once

#include "audio_source.h"
#include "waveforms.h"

class Sampler : public AudioSource {
public:
    Sampler();

    void setWave(Wave& wave);

    void trigger(int offset = 0);

    void getSamples(float* buffer, int numFrames) override;

private:
    Wave wave;
    int currentIndex;  // Текущий индекс воспроизведения
    bool isPlaying;    // Активен ли звук
    int startOffset;   // offset (в фреймах) для начала воспроизведения текущего триггера
};