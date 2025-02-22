#pragma once

#include "audio_source.h"
#include "sampler.h"
#include "waveforms.h"

class Metronome : public AudioSource {
public:
    Metronome(double bpm, Wave sound1, Wave sound2);

    void run();

    void stop();

    void getSamples(float* buffer, int numFrames) override;

private:
    bool isPlaying;
    double bpm;
    double samplesPerTick; // дробное число сэмплов между ударами
    double phaseAcc;       // аккумулятор сэмплов для определения момента клика
    int tickPlaybackPos;   // -1, если тик не воспроизводится, или текущий индекс клика (0..metronomeSound.length-1)
    int tickCounter;

    Sampler sound1Sampler;
    Sampler sound2Sampler;
};