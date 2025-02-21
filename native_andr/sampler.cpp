#include "sampler.h"
#include <cstring>

Sampler::Sampler() : isPlaying(false) {}

void Sampler::setWave(Wave &wave) {
    this->wave = wave;
}

void Sampler::trigger() {
    isPlaying = true;
    currentIndex = 0;
}

void Sampler::getSamples(float* buffer, int numFrames) {
    // Если звук не активен, сразу заполняем буфер тишиной
    if (!isPlaying) {
        std::memset(buffer, 0, sizeof(float) * numFrames * 2);
        return;
    }

    // Сколько сэмплов осталось в вейве?
    int remainingSamples = wave.length - currentIndex;
    // Сколько фреймов (каждый фрейм – 2 сэмпла для стерео) можно скопировать без выхода за пределы
    int framesToCopy = (remainingSamples < numFrames) ? remainingSamples : numFrames;

    //todo optimize: make wave stereo and use memcpy instead of cycle
    for (int i = 0; i < framesToCopy; i++) {
        float sample = wave.data[currentIndex + i];
        buffer[2 * i] = sample;
        buffer[2 * i + 1] = sample;
    }

    currentIndex += framesToCopy;

    if (framesToCopy < numFrames) {
        int remainingFrames = numFrames - framesToCopy;
        std::memset(buffer + (2 * framesToCopy), 0, sizeof(float) * remainingFrames * 2);
        isPlaying = false;
    } else if (currentIndex >= wave.length) {
        isPlaying = false;
    }
}