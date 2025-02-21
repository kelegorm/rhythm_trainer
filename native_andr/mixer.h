#pragma once

#include <vector>
#include "audio_source.h"

class Mixer {
public:
    void addSource(AudioSource* source);
    void mix(float* output, int numFrames);
private:
    std::vector<AudioSource*> sources;
};