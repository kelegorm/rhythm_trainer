#include <android/log.h>
#include <math.h>
#include <stdarg.h>
#include <stdlib.h>

#define LOG_TAG "Native Sound PLayer"

void alog(const char *message, ...) {
    va_list args;
    va_start(args, message);
    __android_log_vprint(ANDROID_LOG_INFO, LOG_TAG, message, args);
    va_end(args);
}

#define SAMPLE_RATE 44100
#define FREQUENCY 440.0  // Частота синусоиды в Гц

// Структура для хранения синусоиды и её длины.
typedef struct {
    float* data;
    int length;
} Wave;

Wave getSinewave(int sample_count);

void playLeft() {
    alog("Play Left!");

    Wave wave = getSinewave(256);

    // Выводим первые 10 значений синусоиды в лог для проверки.
    alog("Generated Sine Wave Samples (Length: %d):", wave.length);
    for (int i = 0; i < 10 && i < wave.length; i++) {
        alog("Sample %d: %f", i, wave.data[i]);
    }
}

Wave getSinewave(int sample_count) {
    Wave result;
    result.data = (float*)malloc(sample_count * sizeof(float));

    if (result.data == NULL) {
        alog("Memory allocation failed for sine wave generating.");
        result.length = 0;
        return result;
    }

    result.length = sample_count;

    for (int i = 0; i < sample_count; i++) {
        result.data[i] = sinf(2.0f * 3.14159f * FREQUENCY * ((float)i / SAMPLE_RATE));
    }

    return result;
}