#pragma once

#include "audio_source.h"
#include "sampler.h"
#include "transport.h"
#include "waveforms.h"

class Metronome : public AudioSource {
public:
    Metronome(Transport* transport, Wave sound1, Wave sound2);

    void run();

    void stop();

    void getSamples(float* buffer, int numFrames) override;

private:
    bool isEnabled;

    Transport* transport;

    Sampler sound1Sampler;
    Sampler sound2Sampler;
};