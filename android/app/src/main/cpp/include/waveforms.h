#pragma once

#include <cmath>
#include <vector>
#include "audio_config.h"
#include "my_log.h"

/**
 * @brief Immutable stereo audio _wave.
 *
 * This struct stores interleaved stereo audio samples in a const vector.
 * The number of numFrames (samples per channel) is computed from the vector size.
 * Note: The Wave is always stereo.
 */
struct Wave {
    /// Interleaved stereo audio samples.
    const std::vector<float> data;
    /// Number of numFrames (samples per channel).
    const int numFrames;

    /**
     * @brief Constructs a Wave from the given audio data.
     *
     * The input data is assumed to be interleaved stereo. The constructor checks that
     * the data vector size is even. Ownership of the data is transferred (moved),
     * so the input vector will be destroyed.
     *
     * @param data A vector containing audio samples.
     * @throw std::invalid_argument if the data size is not even.
     */
    explicit Wave(std::vector<float> data)
            : data(std::move(data)),
              numFrames(computeFrames(this->data))
    {}

    /**
     * @brief Computes the number of numFrames (samples per channel) for stereo audio.
     *
     * @param data A vector of audio samples.
     * @return The number of numFrames, computed as data.size() / 2.
     * @throw std::invalid_argument if data.size() is not even.
     */
    static int computeFrames(const std::vector<float>& data) {
        if (data.size() % 2 != 0) {
            throw std::invalid_argument("Wave: data vector size must be even (stereo interleaved)");
        }
        return static_cast<int>(data.size() / 2);
    }

    /**
     * @brief Converts mono audio data to stereo.
     *
     * This static method takes a vector containing mono audio samples,
     * duplicates each sample for left and right channels, and returns a new Wave object.
     *
     * @param monoData A vector containing mono audio samples.
     * @return A new Wave object with stereo audio data.
     */
    static Wave monoToStereo(const std::vector<float>& monoData) {
        std::vector<float> stereoData;
        stereoData.reserve(monoData.size() * 2);
        for (float sample : monoData) {
            stereoData.push_back(sample); // left channel
            stereoData.push_back(sample); // right channel
        }
        return Wave(stereoData);
    }
};

Wave getSineWave(int sampleCount, float freq);