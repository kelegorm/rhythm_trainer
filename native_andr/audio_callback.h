#pragma once

#include <oboe/Oboe.h>
#include "mixer.h"
#include "transport.h"
#include "waveforms.h"  // Где лежат leftSound и rightSound

class AudioCallback : public oboe::AudioStreamDataCallback {
public:
    explicit AudioCallback(Transport* transport, Mixer* mixer);

    oboe::DataCallbackResult onAudioReady(
            oboe::AudioStream* stream, void* audioData, int32_t numFrames) override;
private:
    Mixer* mixer;
    Transport* transport;
};