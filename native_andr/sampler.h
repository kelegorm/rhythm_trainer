#pragma once

#include "audio_source.h"
#include "waveforms.h"
#include <memory>

class Sampler : public AudioSource {
public:
    explicit Sampler(const std::shared_ptr<const Wave>& wave = nullptr);

    void setWave(const std::shared_ptr<const Wave>& wave);

    void trigger(int offset = 0);

    void stop();

    void getSamples(float* buffer, int numFrames) override;

    bool isPlaying;  // Активен ли звук

private:
    std::shared_ptr<const Wave> _wave;

    /// Current playback index (in frames)
    int _currentIndex;

    /// Offset (in frames) for playback start
    int _startOffset;

    /// Frame when fade out will apply  to the wave t prevent click.
    int fadeOutStartWaveFrame = 0;

    void calcFadeOutStart();
};