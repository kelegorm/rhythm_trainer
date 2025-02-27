#pragma once

#include "audio_source.h"
#include "waveforms.h"

class Sampler : public AudioSource {
public:
    Sampler(Wave wave = Wave());

    void setWave(Wave& wave);

    void trigger(int offset = 0);

    void stop();

    void getSamples(float* buffer, int numFrames) override;

    bool isPlaying;  // Активен ли звук

private:
    Wave wave;
    int currentIndex;  // Текущий индекс воспроизведения
    int startOffset;   // offset (в фреймах) для начала воспроизведения текущего триггера
};