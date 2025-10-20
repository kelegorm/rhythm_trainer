#include <algorithm> // std::fill
#include "core/audio_source.h"

class SilentSource : public IAudioSource {
public:
    void getSamples(float* out, int32_t numFrames) override {
        if (!out || numFrames <= 0) return;

        std::fill(out, out + numFrames * 2, 0.0f);
    }

    float getVolume() override {return 1.0; }
};