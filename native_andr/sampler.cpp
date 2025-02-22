#include "sampler.h"
#include <cstring>

Sampler::Sampler() : isPlaying(false), startOffset(0) {}

void Sampler::setWave(Wave &wave) {
    this->wave = wave;
}

void Sampler::trigger(int offset) {
    isPlaying = true;
    currentIndex = 0;
    startOffset = offset;
}

void Sampler::stop() {
    isPlaying = false;
    currentIndex = 0;
    startOffset = 0;
}

void Sampler::getSamples(float* buffer, int numFrames) {
    // it makes logic much simpler
    std::memset(buffer, 0, sizeof(float) * numFrames * 2);

    // Если звук не активен, сразу заполняем буфер тишиной
    if (!isPlaying) {
        return;
    }

    if (startOffset >= numFrames) {
        startOffset -= numFrames;
        return;
    }

    int playStartFrame = 0;
    // Если это первый вызов после trigger и задан offset,
    // оставляем первые startOffset фреймов нулевыми.
    if (startOffset > 0) {
        playStartFrame = startOffset;
        startOffset = 0; // офсет применён, сбрасываем его
    }

    // Сколько сэмплов осталось в вейве?
    int soundFramesLeft = wave.length - currentIndex;
    int framesAvailableInBuffer = numFrames - playStartFrame;
    // Сколько фреймов (каждый фрейм – 2 сэмпла для стерео) можно скопировать без выхода за пределы
    int framesToCopy = (soundFramesLeft < framesAvailableInBuffer)
            ? soundFramesLeft
            : framesAvailableInBuffer;

    //todo optimize: make wave stereo and use memcpy instead of cycle
    for (int i = 0; i < framesToCopy; i++) {
        float sample = wave.data[currentIndex + i];
        buffer[2 * (playStartFrame + i)] = sample;
        buffer[2 * (playStartFrame + i) + 1] = sample;
    }

    currentIndex += framesToCopy;
    if (currentIndex >= wave.length) {
        isPlaying = false;
    }
}