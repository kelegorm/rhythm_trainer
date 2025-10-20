#include "dsp/core/audio_host.h"

AudioHost::AudioHost() : root_(std::make_shared<SilentSource>()) {}

void AudioHost::process(float* buffer, int32_t numFrames) {
    if (root_) {
        root_->getSamples(buffer, numFrames); // пока используем текущий API
    } else if (buffer && numFrames > 0) {
        std::memset(buffer, 0, sizeof(float) * numFrames * 2);
    }
}

void AudioHost::swapSource(std::shared_ptr<IAudioSource> newRoot) {
    root_ = std::move(newRoot);
}
