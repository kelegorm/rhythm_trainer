#include "audio_callback.h"

AudioCallback::AudioCallback(Transport* transport, Mixer* mixer)
    : transport(transport),
      mixer(mixer)
{

}

oboe::DataCallbackResult AudioCallback::onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) {
    auto *outputData = static_cast<float *>(audioData);

    mixer->mix(outputData, numFrames);

    transport->update(numFrames);

    return oboe::DataCallbackResult::Continue;
}
