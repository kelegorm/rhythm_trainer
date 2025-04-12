#pragma once

#include <memory>
#include <oboe/Oboe.h>
#include "mixer.h"
#include "transport.h"
#include "waveforms.h"  // Где лежат leftSound и rightSound

class AudioCallback : public oboe::AudioStreamDataCallback {
public:
    explicit AudioCallback(
        const std::shared_ptr<Transport>& transport,
        const std::shared_ptr<Mixer>& mixer
    );

    oboe::DataCallbackResult onAudioReady(
            oboe::AudioStream* stream, void* audioData, int32_t numFrames) override;

    void resetBusy() {
        previousNumFrames = -1;
        storedMixTime = 0;
    }

private:
    const std::shared_ptr<Mixer> mixer;
    const std::shared_ptr<Transport> transport;

    int previousNumFrames = -1; // We save it to check if numFrames was changed.
    int storedMixTime = 0;      // Longest time mix took, microseconds. Zero means no value.
    int counter = 0;

    void logXRun(oboe::AudioStream* stream);
};