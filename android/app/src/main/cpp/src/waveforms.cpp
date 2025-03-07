#include "../include/waveforms.h"

using std::vector;

namespace {
    std::vector<float> makeSineTable(int size);

    constexpr float twoPi = 6.283185307179586476925286766559f;

    constexpr int tableSize = 2048;
    std::vector<float> sineTable = makeSineTable(tableSize);

    std::vector<float> makeSineTable(int size) {
        std::vector<float> result(size);

        auto factor = twoPi / size;
        float* p = result.data();

        for (int i = 0; i < size; i++) {
            float phase = factor * i;
            *p++ = sinf(phase);
        }

        return result;
    }
}

Wave getSineWave_table(int sampleCount, float freq) {
    vector<float> samples(sampleCount * 2);
    double phase = 0.0;
    double phaseIncrement = static_cast<double>(freq) / SAMPLE_RATE;
    const float* table = sineTable.data();
    float* p = samples.data();

    for (int i = 0; i < sampleCount; i++) {
        // Вычисляем индекс: не дробим, берем целую часть
        int index = static_cast<int>(phase * tableSize);
        float sample = table[index];

        *p++ = sample; // левый канал
        *p++ = sample; // правый канал

        phase += phaseIncrement;
        if (phase >= 1.0) {
            phase -= 1.0;
        }
    }
    return Wave{samples};
}

Wave getSineWave(int sampleCount, float freq) {
    return getSineWave_table(sampleCount, freq);

//    vector<float> samples(sampleCount * 2);
//    float factor = twoPi * freq / SAMPLE_RATE;
//
//    for (int i = 0; i < sampleCount; i++) {
//        float sample = sinf(factor * i);
//        samples[i * 2] = sample;
//        samples[i * 2 + 1] = sample;
//    }
//
//    return Wave{samples};
}