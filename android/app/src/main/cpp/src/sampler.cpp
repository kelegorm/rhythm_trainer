#include "my_log.h"
#include "sampler.h"
#include "wave_renderer.h"
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
      _noteStart(0)
{
    calcFadeOutStart();
}

void Sampler::setWave(const shared_ptr<const Wave>& wave) {
    this->_wave = wave;
    isPlaying = false;

    calcFadeOutStart();
}

void Sampler::trigger(int offset) {
    isPlaying = true;
    _noteStart = offset;
}

void Sampler::stop() {
    isPlaying = false;
}

void Sampler::getSamples(float* buffer, int numFrames) {
    // it makes logic much simpler
    memset(buffer, 0, sizeof(float) * numFrames * 2);

    // Если звук не активен, сразу заполняем буфер тишиной
    if (!isPlaying) { return; }

    if (!_wave) {
        // throw or mark, it's a big issue. Or not? Sampler in DAw can be without audio data as init state.
        return;
    };

    if (_noteStart >= numFrames) {
        _noteStart -= numFrames;
        return;
    }

    // copy audio to buffer
    WaveRenderer::copy(
        buffer, numFrames,
        _wave->data.data(), _wave->numFrames, _noteStart
    );

    // apply fade out
    int fadeOutOffset = fadeOutStartWaveFrame + _noteStart;
    WaveRenderer::multiply_table(
        buffer, numFrames,
        fadeOutTable, fadeOutOffset
    );

    _noteStart -= numFrames;
    if (_noteStart + _wave->numFrames <= 0) {
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
