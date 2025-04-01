#pragma once

#include "audio_source.h"
#include "waveforms.h"
#include <memory>

class Sampler : public AudioSource {
public:
    explicit Sampler(const std::shared_ptr<const Wave>& wave = nullptr);

    float getVolume() override {return 1.0; }

    void setWave(const std::shared_ptr<const Wave>& wave);

    void trigger(int offset = 0);

    void stop();

    void getSamples(float* buffer, int numFrames) override;

    bool isPlaying;  // Активен ли звук

private:
    std::shared_ptr<const Wave> _wave;

    /// Current Wave position relatively to current buffer, in frames.
    ///
    /// Positive value means wave will start play in some future.
    /// Negative value means wave started to play some time ago.
    ///
    /// Each buffer tick we decrement _noteStart by buffer size.
    int _noteStart;

    /// Frame when fade out will apply  to the wave t prevent click.
    int fadeOutStartWaveFrame = 0;

    void calcFadeOutStart();
};