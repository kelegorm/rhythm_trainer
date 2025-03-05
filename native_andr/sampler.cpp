#include "my_log.h"
#include "sampler.h"
#include <cstring>

using std::shared_ptr;
using std::memcpy;
using std::memset;

Sampler::Sampler(const shared_ptr<const Wave>& wave)
    : _wave(wave),
      isPlaying(false),
      _startOffset(0),
      _currentIndex(0)
{}

void Sampler::setWave(const shared_ptr<const Wave>& wave) {
    this->_wave = wave;
    isPlaying = false;
    _currentIndex = 0;
    _startOffset = 0;
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

    int playStartFrame = 0;
    // Если это первый вызов после trigger и задан offset,
    // оставляем первые _startOffset фреймов нулевыми.
    if (_startOffset > 0) {
        playStartFrame = _startOffset;
        _startOffset = 0; // офсет применён, сбрасываем его
    }

    // Сколько сэмплов осталось в вейве?
    int framesLeftInWave = _wave->numFrames - _currentIndex;
    int framesAvailableInBuffer = numFrames - playStartFrame;
    // Сколько фреймов (каждый фрейм – 2 сэмпла для стерео) можно скопировать без выхода за пределы
    int framesToCopy = (framesLeftInWave < framesAvailableInBuffer)
            ? framesLeftInWave
            : framesAvailableInBuffer;

    memcpy(
        buffer + playStartFrame * 2,              // Destination: смещение в буфере в элементах float
        _wave->data.data() + _currentIndex * 2,     // Source: смещение в векторе _wave->data
        framesToCopy * 2 * sizeof(float)            // Количество байт для копирования
    );

    _currentIndex += framesToCopy;
    if (_currentIndex >= _wave->numFrames) {
        isPlaying = false;
    }
}