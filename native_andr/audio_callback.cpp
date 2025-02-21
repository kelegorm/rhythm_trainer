#include "audio_callback.h"

AudioCallback::AudioCallback(Mixer* mixer) : mixer(mixer) {}

oboe::DataCallbackResult AudioCallback::onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) {
    auto *outputData = static_cast<float *>(audioData);

    mixer->mix(outputData, numFrames);

    return oboe::DataCallbackResult::Continue;
}
