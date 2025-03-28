#include "mixer.h"
#include "my_log.h"
#include <cstring>
#include <memory>

using std::fill;
using std::shared_ptr;
using std::vector;

void Mixer::addSource(const shared_ptr<AudioSource>& source) {
    if (!source) {
        // what to do then? throw?
        return;
    }
    sources.push_back(source);
}

void Mixer::mix(float* output, int numFrames) {
    memset(output, 0, sizeof(float) * numFrames * 2);

    if (tempBuffer.size() != numFrames * 2) {
        tempBuffer.resize(numFrames * 2);
    }

    for (auto src : sources) {
        if (!src) {
            // todo this is the issue, need to log.
            continue;
        }

        fill(tempBuffer.begin(), tempBuffer.end(), 0);
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

void Mixer::clear() {
    sources.clear();
}
