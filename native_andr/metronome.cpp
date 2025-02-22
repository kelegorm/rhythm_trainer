#include "audio_config.h"
#include "metronome.h"
#include <cstring>

Metronome::Metronome(double bpm, Wave sound1, Wave sound2)
    : isPlaying(false),
      bpm(bpm),
      phaseAcc(0.0),
      tickPlaybackPos(-1)
{
    // Вычисляем количество сэмплов между ударами
    samplesPerTick = (SAMPLE_RATE * 60.0) / bpm;
    sound1Sampler.setWave(sound1);
    sound2Sampler.setWave(sound2);
}

void Metronome::run() {
    isPlaying = true;
    phaseAcc = 0.0;
    sound1Sampler.trigger(0);
}

void Metronome::stop() {
    isPlaying = false;
}

void Metronome::getSamples(float *buffer, int numFrames) {
    if (phaseAcc + numFrames >= samplesPerTick) {
        int offset = (int)(samplesPerTick - phaseAcc);
        sound1Sampler.trigger(offset);
        phaseAcc = phaseAcc + numFrames - samplesPerTick;
    } else {
        phaseAcc += numFrames;
    }

    sound1Sampler.getSamples(buffer, numFrames);
}