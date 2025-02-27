#include "waveforms.h"

#define FREQUENCY 300.0  // Частота синусоиды в Гц
#define FREQUENCY2 600.0  // Частота синусоиды в Гц

Wave leftSound = getSinewave(4024, FREQUENCY);
Wave rightSound = getSinewave(3024, FREQUENCY2);

Wave getSinewave(int sample_count, float freq) {
    Wave result;
    result.data = (float*)malloc(sample_count * sizeof(float)); // TODO release memory??

    if (result.data == NULL) {
        alog("Memory allocation failed for sine wave generating.");
        result.length = 0;
        return result;
    }

    result.length = sample_count;

    const float twoPi = 6.283185307179586476925286766559f;
    for (int i = 0; i < sample_count; i++) {
        result.data[i] = sinf(twoPi * freq * ((float)i / SAMPLE_RATE));
    }

    return result;
}