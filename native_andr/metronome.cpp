#include "audio_config.h"
#include "metronome.h"
#include <cstring>

Metronome::Metronome(double bpm, Wave sound1, Wave sound2)
    : isPlaying(false),
      bpm(bpm),
      phaseAcc(0.0),
      tickPlaybackPos(-1),
      tickCounter(0)
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
    tickCounter = 0;
}

void Metronome::stop() {
    isPlaying = false;
    sound1Sampler.stop();
    sound2Sampler.stop();
}

void Metronome::getSamples(float *buffer, int numFrames) {
    if (phaseAcc + numFrames >= samplesPerTick) {
        int offset = (int)(samplesPerTick - phaseAcc);

        if (tickCounter == 0) {
            sound2Sampler.trigger(offset);   // Sound2 on the first tick
        } else {
            sound1Sampler.trigger(offset);   // Sound1 on the next three ticks
        }
        tickCounter = (tickCounter + 1) % 4; // Increment tickCounter and reset to 0 after 4th tick

        phaseAcc = phaseAcc + numFrames - samplesPerTick;
    } else {
        phaseAcc += numFrames;
    }

    if (sound1Sampler.isPlaying) {
        sound1Sampler.getSamples(buffer, numFrames);
    } else {
        sound2Sampler.getSamples(buffer, numFrames);
    }
}