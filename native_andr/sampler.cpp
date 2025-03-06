#include "my_log.h"
#include "sampler.h"
#include <cstring>
#include <vector>

using std::shared_ptr;
using std::memcpy;
using std::memset;
using std::vector;
using std::max;
using std::min;

namespace {
    vector<float> generateLinearFadeOut(size_t length);

    size_t fadeOutSize = 512;
    vector<float> fadeOutTable = generateLinearFadeOut(fadeOutSize);

    vector<float> generateLinearFadeOut(size_t length) {
        std::vector<float> result(length);
        float factor = 1.0f / (length - 1);

        for (size_t i = 0; i < length; ++i) {
            result[i] = 1.0f - factor * i;
        }

        return result;
    }
}

Sampler::Sampler(const shared_ptr<const Wave>& wave)
    : _wave(wave),
      isPlaying(false),
      _startOffset(0),
      _currentIndex(0)
{
    calcFadeOutStart();
}

void Sampler::setWave(const shared_ptr<const Wave>& wave) {
    this->_wave = wave;
    isPlaying = false;
    _currentIndex = 0;
    _startOffset = 0;

    calcFadeOutStart();
}

void Sampler::trigger(int offset) {
    isPlaying = true;
    _currentIndex = 0;
    _startOffset = offset;
}

void Sampler::stop() {
    isPlaying = false;
    _currentIndex = 0;
    _startOffset = 0;
}

void Sampler::getSamples(float* buffer, int numFrames) {
    // it makes logic much simpler
    memset(buffer, 0, sizeof(float) * numFrames * 2);

    // Если звук не активен, сразу заполняем буфер тишиной
    if (!isPlaying) {
        return;
    }

    if (!_wave) {
        // throw or mark, it's a big issue. Or not? Sampler in DAw can be without audio data as init state.
        return;
    };

    if (_startOffset >= numFrames) {
        _startOffset -= numFrames;
        return;
    }

    int playStartBufferFrame = 0;
    // Если это первый вызов после trigger и задан offset,
    // оставляем первые _startOffset фреймов нулевыми.
    if (_startOffset > 0) {
        playStartBufferFrame = _startOffset;
        _startOffset = 0; // офсет применён, сбрасываем его
    }

    // Сколько сэмплов осталось в вейве?
    int framesLeftInWave = _wave->numFrames - _currentIndex;
    int framesAvailableInBuffer = numFrames - playStartBufferFrame;
    // Сколько фреймов (каждый фрейм – 2 сэмпла для стерео) можно скопировать без выхода за пределы
    int framesToCopy = (framesLeftInWave < framesAvailableInBuffer)
            ? framesLeftInWave
            : framesAvailableInBuffer;

    memcpy(
        buffer + playStartBufferFrame * 2,              // Destination: смещение в буфере в элементах float
        _wave->data.data() + _currentIndex * 2,     // Source: смещение в векторе _wave->data
        framesToCopy * 2 * sizeof(float)            // Количество байт для копирования
    );

    if (_currentIndex + framesToCopy > fadeOutStartWaveFrame) {
        // Точка начала fadeOut в текущем буфере
        size_t startInBuffer = (fadeOutStartWaveFrame > _currentIndex)
                               ? fadeOutStartWaveFrame - _currentIndex
                               : 0;

        for (size_t i = startInBuffer; i < framesToCopy; ++i) {
            size_t fadeIndex = (_currentIndex + i) - fadeOutStartWaveFrame;
            if (fadeIndex >= fadeOutSize) break;

            float volume = fadeOutTable[fadeIndex];
            buffer[i * 2] *= volume;
            buffer[i * 2 + 1] *= volume;
        }
    }

    _currentIndex += framesToCopy;
    if (_currentIndex >= _wave->numFrames) {
        isPlaying = false;
    }
}

void Sampler::calcFadeOutStart() {
    if (!_wave) {
        fadeOutStartWaveFrame = 0;
        return;
    }

    if (_wave->numFrames > fadeOutSize) {
        fadeOutStartWaveFrame = _wave->numFrames - fadeOutSize;
    } else {
        // короткий wave, затухание начинается сразу. Но получается, что до конца затухание
        // может даже не дойти. В любом случае, сделали щелчок тише.
        fadeOutStartWaveFrame = 0;
    }
}
