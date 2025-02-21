#pragma once

#include <oboe/Oboe.h>
#include "waveforms.h"  // Где лежат leftSound и rightSound
#include "mixer.h"

class AudioCallback : public oboe::AudioStreamDataCallback {
public:
    explicit AudioCallback(Mixer* mixer);

    oboe::DataCallbackResult onAudioReady(
            oboe::AudioStream* stream, void* audioData, int32_t numFrames) override;
private:
    Mixer* mixer;
};