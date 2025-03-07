//
// Created by Dmitry on 6.3.25..
//

#include "wave_renderer.h"
#include <cassert>

using std::min;
using std::vector;

WaveRenderer::CopyParams WaveRenderer::calcCopyParams(size_t bufferSize, size_t srcSize, int srcOffset) {
    if (srcOffset + srcSize <= 0) return CopyParams{};
    if (srcOffset >= static_cast<int>(bufferSize)) return CopyParams{};

    // Index in src we start to copy.
    size_t effectiveSrcStart    = (srcOffset < 0) ? static_cast<size_t>(-srcOffset) : 0;
    size_t effectiveBufferStart = (srcOffset >= 0) ? static_cast<size_t>(srcOffset) : 0;

    assert(effectiveSrcStart < srcSize);
    assert(effectiveBufferStart < bufferSize);

    if (effectiveSrcStart >= srcSize || effectiveBufferStart >= bufferSize) return CopyParams{};

    size_t srcLeft = srcSize - effectiveSrcStart;
    size_t bufferLeft = bufferSize - effectiveBufferStart;
    size_t copyLength = min(srcLeft, bufferLeft);

    if (copyLength == 0) return CopyParams{};

    assert(effectiveSrcStart + copyLength <= srcSize);
    assert(effectiveBufferStart + copyLength <= bufferSize);

    return CopyParams{
        effectiveSrcStart,
        effectiveBufferStart,
        copyLength
    };
}

void WaveRenderer::copy(
        float* buffer, size_t bufferSize,
        const float* src, size_t srcSize, int srcOffset
) {
    auto params = calcCopyParams(bufferSize, srcSize, srcOffset);

    if (params.copyLength > 0) {
        std::memcpy(
            buffer + params.bufferStart * 2,
            src + params.srcStart * 2,
            params.copyLength * 2 * sizeof(float)
        );
    }
}

void WaveRenderer::copy_w(
        float* buffer, size_t bufferSize,
        const float* src, size_t srcSize, int srcOffset,
        size_t windowStart, size_t windowEnd
) {


}

void WaveRenderer::multiply_table(
        float* buffer, size_t bufferSize,
        const vector<float>& table, int tableOffset
) {
    auto params = calcCopyParams(bufferSize, table.size(), tableOffset);

    if (params.copyLength > 0) {
        for (size_t i = 0; i < params.copyLength; ++i) {
            float volume = table[params.srcStart + i];

            buffer[(params.bufferStart + i) * 2] *= volume;
            buffer[(params.bufferStart + i) * 2 + 1] *= volume;
        }
    }

//    if (_noteStart + framesToCopy > fadeOutStartWaveFrame) {
//        // Точка начала fadeOut в текущем буфере
//        size_t startInBuffer = (fadeOutStartWaveFrame > _noteStart)
//                               ? fadeOutStartWaveFrame - _noteStart
//                               : 0;
//

//    }
}