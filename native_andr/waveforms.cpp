#include "waveforms.h"

using std::vector;

namespace {
    constexpr float twoPi = 6.283185307179586476925286766559f;
}

Wave getSineWave(int sampleCount, float freq) {
    vector<float> samples(sampleCount);
    float factor = twoPi * freq / SAMPLE_RATE;

    for (int i = 0; i < sampleCount; i++) {
        float sample = sinf(factor * i);
        samples[i * 2] = sample;
        samples[i * 2 + 1] = sample;
    }

    return Wave{samples};
}