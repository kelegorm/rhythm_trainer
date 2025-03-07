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
private:
    const std::shared_ptr<Mixer> mixer;
    const std::shared_ptr<Transport> transport;
};