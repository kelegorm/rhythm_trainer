//
// Created by Dmitry on 6.3.25..
//

#pragma once

#include <vector>

// Methods to render waves into the buffer.
class WaveRenderer {
public:
    /**
     * @brief Copies source into the buffer.
     *
     * Actual copy length could be shorter than buffer size if src is too short or starts before
     * buffer.
     *
     * Buffer and source is a stereo interlaced arrays. Actual size of each is twice long. All
     * sizes and lengths are set in frames (one frame is two floats for leanf a ringht channels).
     *
     * It's better to pass actual buffer and source sizes, so func will check carefully out of
     * boundaries issues.
     *
     * @param buffer it's where we copy data of source.
     * @param bufferSize buffer size in frames.
     *
     * @param src is a audio data you wanna to copy into the buffer. It should be pointer to first
     * frame.
     * @param srcSize size of source in frames. Func use in only to carefully checks all out of
     * boundaries issues.
     * @param srcOffset offset in frames for source start relatively to the buffer start. Negative means
     * source started before buffer.
     */
    static void copy(
            float* buffer, size_t bufferSize,
            const float* src, size_t srcSize, int srcOffset
    );

    /**
     * @brief Exactly same method as copy, but with additional window.
     *
     * When you need don't need to fill full buffer but only part of that. Window - is a part of
     * buffer you need to fill. Window is a period [windowStart, windowEnd).
     *
     * @param windowStart index in buffer where we start copy.
     * @param windowEnd index where we have stop copy. Method doesn't copy to that index.
     */
    static void copy_w(
            float* buffer, size_t bufferSize,
            const float* src, size_t srcSize, int srcOffset,
            size_t windowStart, size_t windowEnd
    );

    /**
     * @brief Changes buffer's samples loudness.
     *
     * @param buffer
     * @param bufferSize
     * @param table is a mono-source. Each frame is one value which will be applied to left and
     * right values in buffer.
     * @param tableOffset When table starts to apply. It's offset relatively to buffer start.
     * Positive value means table will start to modify loudness starting with buffer[tableOffset].
     */
    static void multiply_table(
            float* buffer, size_t bufferSize,
            const std::vector<float>& table, int tableOffset
    );
};
