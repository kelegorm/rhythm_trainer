//
// Created by Dmitry on 6.3.25..
//

#include "../include/my_log.h"
#include "../include/wave_renderer.h"
#include <cassert>

using std::min;
using std::vector;

void WaveRenderer::copy(
        float* buffer, size_t bufferSize,
        const float* src, size_t srcSize, int srcOffset
) {
    if (srcOffset + srcSize <= 0) return;
    if (srcOffset >= static_cast<int>(bufferSize)) return;

    // Index in src we start to copy.
    size_t effectiveSrcStart    = (srcOffset < 0) ? static_cast<size_t>(-srcOffset) : 0;
    size_t effectiveBufferStart = (srcOffset >= 0) ? static_cast<size_t>(srcOffset) : 0;

    assert(effectiveSrcStart < srcSize);
    assert(effectiveBufferStart < bufferSize);

    if (effectiveSrcStart >= srcSize || effectiveBufferStart >= bufferSize) return;

    size_t srcLeft = srcSize - effectiveSrcStart;
    size_t bufferLeft = bufferSize - effectiveBufferStart;
    size_t copyLength = min(srcLeft, bufferLeft);

    if (copyLength == 0) return;

    assert(effectiveSrcStart + copyLength <= srcSize);
    assert(effectiveBufferStart + copyLength <= bufferSize);

    std::memcpy(
        buffer + effectiveBufferStart * 2,
        src + effectiveSrcStart * 2,
        copyLength * 2 * sizeof(float)
    );
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
//    size_t effectiveSrcStart    = (srcOffset < 0) ? static_cast<size_t>(-srcOffset) : 0;
//    size_t effectiveBufferStart = (srcOffset >= 0) ? static_cast<size_t>(srcOffset) : 0;
//
//    size_t srcLeft = srcSize - effectiveSrcStart;
//    size_t bufferLeft = bufferSize - effectiveBufferStart;
//    size_t copyLength = min(srcLeft, bufferLeft);

//    if (_noteStart + framesToCopy > fadeOutStartWaveFrame) {
//        // Точка начала fadeOut в текущем буфере
//        size_t startInBuffer = (fadeOutStartWaveFrame > _noteStart)
//                               ? fadeOutStartWaveFrame - _noteStart
//                               : 0;
//
//        for (size_t i = startInBuffer; i < framesToCopy; ++i) {
//            size_t fadeIndex = (_noteStart + i) - fadeOutStartWaveFrame;
//            if (fadeIndex >= fadeOutSize) break;
//
//            float volume = fadeOutTable[fadeIndex];
//            buffer[i * 2] *= volume;
//            buffer[i * 2 + 1] *= volume;
//        }
//    }
}