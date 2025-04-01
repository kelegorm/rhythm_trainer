#pragma once

#include "audio_source.h"
#include "sampler.h"
#include "transport.h"
#include "waveforms.h"
#include <memory>

class Metronome : public AudioSource {
public:
    Metronome(
        const std::shared_ptr<Transport>& transport,
        const std::shared_ptr<const Wave>& sound1,
        const std::shared_ptr<const Wave>& sound2
    );

    void setEnabled(bool newValue);

    void getSamples(float* buffer, int numFrames) override;

private:
    bool isEnabled;

    const std::shared_ptr<Transport> transport;

    Sampler sound1Sampler;
    Sampler sound2Sampler;
};