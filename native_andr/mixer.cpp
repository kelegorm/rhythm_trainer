#include "mixer.h"
#include <cstring>

void Mixer::addSource(AudioSource* source) {
    sources.push_back(source);
}

void Mixer::mix(float* output, int numFrames) {
    ::memset(output, 0, sizeof(float) * numFrames * 2);

    std::vector<float> tempBuffer;//(numFrames * 2, 0); // todo make more global
    tempBuffer.resize(numFrames * 2);

    for (auto src : sources) {
        std::fill(tempBuffer.begin(), tempBuffer.end(), 0);
        src->getSamples(tempBuffer.data(), numFrames);

        for (int i = 0; i < numFrames * 2; ++i) {
            output[i] += tempBuffer[i] * 0.3f;
        }
    }

    for (int i = 0; i < numFrames * 2; i++) {
        if (output[i] > 1.0f) {
            output[i] = 1.0f;
        } else if (output[i] < -1.0f) {
            output[i] = -1.0f;
        }
    }
}