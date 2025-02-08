#pragma once

#include <oboe/Oboe.h>
#include "waveforms.h"  // Где лежат leftSound и rightSound

class AudioCallback : public oboe::AudioStreamDataCallback {
public:
    AudioCallback() = default;

    oboe::DataCallbackResult onAudioReady(
            oboe::AudioStream* stream, void* audioData, int32_t numFrames) override;
};