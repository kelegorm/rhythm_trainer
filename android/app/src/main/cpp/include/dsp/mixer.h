#pragma once

#include "core/audio_source.h"
#include <memory>
#include <vector>

class Mixer {
public:
    void addSource(const std::shared_ptr<IAudioSource>& source);
    void mix(float* output, int numFrames);

    /// Clears all sound sources.
    void clear();
private:
    std::vector<std::shared_ptr<IAudioSource>> sources;
    // Temporary buffer to load samples from next audio source.
    std::vector<float> tempBuffer;
};